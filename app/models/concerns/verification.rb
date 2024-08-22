module Verification
  extend ActiveSupport::Concern

  included do
    scope :residence_verified, -> { where.not(residence_verified_at: nil) }
    scope :level_two_verified, -> { where.not(residence_verified_at: nil) }
    scope :level_three_verified, -> { where.not(residence_verified_at: nil, ife_file_name: nil) }
    scope :level_two_or_three_verified, -> { where('residence_verified_at IS NOT NULL OR ife_file_name IS NOT NULL') }
    #scope :level_two_verified, -> { where("users.level_two_verified_at IS NOT NULL OR (users.residence_verified_at IS NOT NULL) AND verified_at IS NULL") }
    #scope :level_two_or_three_verified, -> { where("users.verified_at IS NOT NULL OR users.level_two_verified_at IS NOT NULL OR (users.residence_verified_at IS NOT NULL)") }
    scope :unverified, -> { where("users.verified_at IS NULL AND (users.level_two_verified_at IS NULL AND (users.residence_verified_at IS NULL))") }
    scope :incomplete_verification, -> { where("(users.residence_verified_at IS NULL AND users.failed_census_calls_count > ?) OR (users.residence_verified_at IS NOT NULL)", 0) }
  end

  def skip_verification?
    Setting["feature.user.skip_verification"].present?
  end

  def verification_email_sent?
    return true if skip_verification?
    email_verification_token.present?
  end

  def verification_sms_sent?
    return true
    # TODO personalizar verificacion
    # return true if skip_verification?
    # unconfirmed_phone.present? && sms_confirmation_code.present?
  end

  def verification_letter_sent?
    return true if skip_verification?
    letter_requested_at.present? && letter_verification_code.present?
  end

  def residence_verified?
    return true if skip_verification?
    residence_verified_at.present?
  end

  def sms_verified?
    return true if skip_verification?
    confirmed_phone.present?
  end

  def basic_info_completed?
    return true if self.born_names.present? &&
      self.paternal_last_name.present? &&
      self.maternal_last_name.present? &&
      self.birthplace.present? &&
      self.date_of_birth.present? &&
      self.gender.present? &&
      self.phone_number.present?
  end

  def level_two_verified?
    return true if self.colonium.present? && basic_info_completed?
    false
  end

  def level_three_verified?
    return true if self.ife.present? && level_two_verified?
    false
  end

  def level_two_or_three_verified?
    level_two_verified? || level_three_verified?
  end

  def level_two_and_three_verified?
    level_two_verified? && level_three_verified?
  end

  def unverified?
    !level_two_or_three_verified?
  end

  def failed_residence_verification?
    !residence_verified? && !failed_census_calls.empty?
  end

  def no_phone_available?
    !verification_sms_sent?
  end

  def user_type
    # level_3_user - TIENE DATOS BÁSICOS, COLONIA E INE
    # level_2_user - TIENE DATOS BÁSICOS Y COLONIA PERO NO TIENE INE
    # level_1_user - LE FALTAN ALGUNOS DATOS BÁSICOS (nombre, apellidos, género, lugar de nacimiento, etc)

    if level_three_verified?
      :level_3_user
    elsif level_two_verified?
      :level_2_user
    else
      :level_1_user
    end
  end

  def sms_code_not_confirmed?
    !sms_verified?
  end
end

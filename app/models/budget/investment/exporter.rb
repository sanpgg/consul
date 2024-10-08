class Budget::Investment::Exporter
  require 'csv'

  def initialize(investments)
    @investments = investments
    @budget_is_new = Budget.find_by(id: investments.first.budget_id).is_new?
  end

  def to_csv

    CSV.generate(headers: true) do |csv|
      csv << headers
      @investments.each { |investment| csv << csv_values(investment) }
    end
  end

  private

  def headers
    [
      I18n.t("admin.budget_investments.index.list.id"),
      I18n.t("admin.budget_investments.index.list.title"),
      'Decisiones',
      'Votos offline',
      'Total',
      I18n.t("admin.budget_investments.index.list.admin"),
      I18n.t("admin.budget_investments.index.list.valuator"),
      I18n.t("admin.budget_investments.index.list.valuation_group"),
      @budget_is_new ? nil : I18n.t("admin.budget_investments.index.list.geozone"),
      I18n.t("admin.budget_investments.index.list.feasibility"),
      I18n.t("admin.budget_investments.index.list.valuation_finished"),
      I18n.t("admin.budget_investments.index.list.selected"),
      I18n.t("admin.budget_investments.index.list.visible_to_valuators"),
      I18n.t("admin.budget_investments.index.list.author_username"),
      'Sector',
      @budget_is_new ? nil : 'Partida',
      @budget_is_new ? nil : 'Sector Propuesta',
      'Imagen',
      'Documento 1',
      'Documento 2',
      'Documento 3',
      'Latitud',
      'Longitud',
      I18n.t("admin.budget_investments.index.list.content"),
      I18n.t("admin.budget_investments.index.list.creation"),
      I18n.t("admin.budget_investments.index.list.updated"),
      'Ganador',
      'Categoría',
      'Tipo'
    ].compact
  end  

  def csv_values(investment)
    [
      investment.id.to_s,
      investment.title,
      investment.ballot_online_count,
      investment.ballot_offline_count,
      investment.ballot_online_count + investment.ballot_offline_count,
      admin(investment),
      investment.assigned_valuators || '-',
      investment.assigned_valuation_groups || '-',
      @budget_is_new ? nil : investment.heading.name,
      price(investment),
      investment.valuation_finished? ? I18n.t('shared.yes') : I18n.t('shared.no'),
      investment.selected? ? I18n.t('shared.yes') : I18n.t('shared.no'),
      investment.visible_to_valuators? ? I18n.t('shared.yes') : I18n.t('shared.no'),
      investment.author.username,
      investment.author.sector,
      @budget_is_new ? nil : investment.heading.name,
      @budget_is_new ? nil : investment.heading.sector,
      investment.image.present? ? "https:#{investment.image_url(:large)}" : '',
      get_documents_url(investment.documents.first),
      get_documents_url(investment.documents.second),
      get_documents_url(investment.documents.third),
      get_latitude(investment),
      get_longitude(investment),
      ActionView::Base.full_sanitizer.sanitize(investment.description),
      investment.created_at.strftime("%d/%m/%Y"),
      investment.updated_at.strftime("%d/%m/%Y"),
      investment.winner,
      investment.tag_list.to_s,
      investment.size
      
    ].compact
  end  

  def admin(investment)
    if investment.administrator.present?
      investment.administrator.name
    else
      I18n.t("admin.budget_investments.index.no_admin_assigned")
    end
  end

  def get_latitude(investment)
    @map_location = MapLocation.where(investment_id: investment.id).first
    if @map_location.nil?
      investment.heading.latitude
    else
      MapLocation.where(investment_id: investment.id).first.try(:latitude)
    end
  end

  def get_longitude(investment)
    @map_location = MapLocation.where(investment_id: investment.id).first
    if @map_location.nil?
      investment.heading.longitude
    else
      MapLocation.where(investment_id: investment.id).first.try(:longitude)
    end
  end

  def get_documents_url(investment)
    return "" if investment.nil?
    url = investment.attachment.url
    "https:#{url}"
  end

  def price(investment)
    price_string = "admin.budget_investments.index.feasibility.#{investment.feasibility}"
    I18n.t(price_string, price: investment.formatted_price)
  end
end

require "rails_helper"

describe Admin::Roles::TableActionsComponent, type: :component do
  let(:user) { create(:user) }
  let(:component) { Admin::Roles::TableActionsComponent.new(user, "manager") }

  it "renders link to add the role for users without the role" do
    render_inline component

    expect(page).to have_css "a[data-method='post']", text: "Add"
  end

  it "renders link to remove the role for users with the role" do
    create(:manager, user: user)

    render_inline component

    expect(page).to have_css "a[data-method='delete']", text: "Delete"
  end
end

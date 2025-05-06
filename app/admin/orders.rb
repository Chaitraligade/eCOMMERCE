ActiveAdmin.register Order do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :user_id, :total, :status, :user_name, :user_email, :user_address, :payment_method, :total_price, :paid
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :total, :status, :user_name, :user_email, :user_address, :payment_method, :total_price, :paid]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  

  permit_params :status, :total_price, :user_id, :shipping_address, :order_date, :payment_status

  index do
    selectable_column
    id_column
    column :user
    column :status
    column :total_price
    # column :order_date
    column :payment_status
    actions
  end

  filter :status
  filter :user
  filter :payment_status
  filter :order_date

  form do |f|
    f.inputs 'Order Details' do
      f.input :status
      f.input :total_price
      f.input :user
      f.input :user_address
      f.input :created_at
      f.input :payment_method
      f.input :payment_status, as: :select, collection: ["Paid", "Unpaid"]
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :status
      row :total_price
      row :user_address
      row :created_at
      row :payment_method
      row :payment_status
    end
  end

  action_item :mark_as_paid, only: :show do
    if resource.payment_status != "Paid"
      link_to "Mark as Paid", mark_as_paid_admin_order_path(resource), method: :patch, class: "button"
    end
  end

  member_action :mark_as_paid, method: :patch do
    resource.update(payment_status: "Paid")
    redirect_to admin_order_path(resource), notice: "Order marked as Paid!"
  end

  action_item :mark_as_unpaid, only: :show do
    if resource.payment_status != "Unpaid"
      link_to "Mark as Unpaid", mark_as_unpaid_admin_order_path(resource), method: :patch, class: "button"
    end
  end

  member_action :mark_as_unpaid, method: :patch do
    resource.update(payment_status: "Unpaid")
    redirect_to admin_order_path(resource), notice: "Order marked as Unpaid!"
  end
end

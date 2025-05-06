ActiveAdmin.register Product do
  permit_params :name, :stock, :description, :price, :category_id, :image

 

  filter :name
  filter :price
  filter :category

  index do
    selectable_column
    id_column
    column :name
    column :price
    column :category
    column "Image" do |product|
      if product.image.attached?
        image_tag product.image.variant(resize_to_limit: [50, 50]).processed, size: "50x50"
      else
        "No Image"
      end
    end
    
    
    actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :price
      row :stock
      row :created_at
      row :updated_at
      row :category
      row "Image" do |product|
        if product.image.attached?
          image_tag product.image.variant(resize_to_limit: [200, 200]).processed
        else
          "No Image"
        end
      end
      
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs do
      f.input :name
      f.input :description
      f.input :price
      f.input :stock
      
      f.input :image, as: :file, hint: (
  if f.object.persisted? && f.object.image.attached?
    image_tag(url_for(f.object.image.variant(resize_to_limit: [100, 100])))
  else
    content_tag(:span, "No image yet")
  end
)
      f.input :category_id, as: :select, collection: Category.pluck(:name, :id)
 
    end
    f.actions
  end
end


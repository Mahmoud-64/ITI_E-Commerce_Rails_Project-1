class Order < ApplicationRecord
    belongs_to :user
    has_many :shopping_carts
    belongs_to :coupon, optional: true
    validate :check_available_items


    

    def user_name
      user.username
    end

    def update_status(status)
      shopping_carts.each do |cart|
        if(cart.status != status)
          return nil
        end
      end
      self.status = status
      self.save
    end

   
    
    before_create :calculate_price
    after_create :submit_cart  
    before_destroy :destroy_carts

  private
    def calculate_price
      shopping_carts = ShoppingCart.carts(user)
      shopping_carts.each do |cart| 
        cart.product.change_available_quantity cart.quantity
        self.price += cart.price
      end
    end

    def submit_cart
      ShoppingCart.submit_current_cart(user, self.id)
    end

    def destroy_carts
      # shopping_carts.destroy_all
      shopping_carts.each do |cart|
        cart.release_holding_quantity
        cart.destroy
      end
    end

    def check_available_items
      shopping_carts.each do |cart|
        unless item_available?(cart)
          errors.add(:quantity, "sorry quantity no available for #{cart.product.title} ")
        end
      end
    end

    def item_available?(cart)
      cart.product.in_stock_quantity >= cart.quantity
    end

end

class HomeController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]

  def index
    @products=Product.paginate(page: params[:page])
    @categories=Category.all()
    @shoppingCarts=ShoppingCart.where(user_id: current_user)
    @shopping_cart = ShoppingCart.new
    # byebug
  end
end

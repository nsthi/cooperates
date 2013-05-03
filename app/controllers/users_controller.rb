class UsersController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!#, except: [:index]
  def index

  end

  def search
    @search = User.search(params[:q])
    @users = @search.result(:distinct => true)
    @search.build_condition if @search.conditions.empty?
  end

  def show
    @user = User.find(params[:id])
    @food = @user.foods
    @ingredients = @user.ingredients.select(:ingredient_name).uniq.sort_by{|u| u.ingredient_name}

    @a=[]
    @b=[]
    @restOfIngred = @allingredients - @user.ingredients
    @user.ingredients.each do |myingredient|
      @restOfIngred.each do |youringredient|
        if youringredient.ingredient_name == myingredient.ingredient_name
              @a << youringredient
        end
      end
    end
    
    @a.each do |restaurant|
      @allusers.each do |user|
        if restaurant.user_id == user.id
          @b << user
        end
      end
    end
    @c =@b.uniq


		@low_stock = []
		Stock.all.each do |s|
			if s.low_quantity > s.quantity
				@low_stock.push(s)
			end
		end

  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
    if current_user.id != params[:id].to_i
     redirect_to user_path(params[:id]), :notice => "You cannot edit #{@user.username}'s profile!"
   end
 end

 def create
  @user = User.new(params[:user])
  if @user.save
    redirect_to @user, notice: "user was successfully created."
  else
    render "new"
  end
end

def update
  @user = User.find(params[:id])
  @user.update_attributes(params[:user])
  respond_with @user
end

def destroy
  @user = user.find(params[:id])
  @user.destroy
  redirect_to users_url
end

def import
  User.import(params[:file])
  redirect_to users_url, notice: "Products imported"
end
end

class UsersController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!#, except: [:index]

  def index
  end

  def search
    if params[:within].present? && (params[:within].to_i > 0)
      @search = User.near([current_user.latitude, current_user.longitude], params[:within]).search(params[:q])
      @test = User.near([current_user.latitude, current_user.longitude], params[:within])
    else
      @search = User.search(params[:q])
      @test = "far"
    end
    @params = params[:q]
    @users = @search.result(:distinct => true)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
  end

  def show
    @user = User.find(params[:id])
    @food = @user.foods
    #@ingredients = @user.ingredients.select(:ingredient_name).uniq.sort_by{|u| u.ingredient_name}
		@ingredients = @user.stocks.select(:ingredient_name).sort_by{|u| u.ingredient_name}

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
			if s.user_id == current_user.id
		  	if s.low_quantity > s.quantity
		    	@low_stock.push(s)
		  	end
			end
  	end

		@clients = []	
		if @user.user_type == "supplier"
			already = false
			User.where(:user_type => "restaurant").each do |rest|
				already = false
				rest.stocks.each do |ing|
					if already == true
						break
					end
					@ingredients.each do |i|
						if i.ingredient_name == ing.ingredient_name
							@clients.push([rest, i.ingredient_name])
							already = true
						end
					end
				end
			end
		end #end supplier block
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

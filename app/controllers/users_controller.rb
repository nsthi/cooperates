class UsersController < ApplicationController
before_filter :authenticate_user!, except: [:index, :show]
  def index
    @users = User.all
  end

  def show
    @users = User.find(params[:user_id][:food_id])
    
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
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
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: "user was successfully updated."
    else
      render "edit"
    end
  end

  def destroy
    @user = user.find(params[:id])
    @user.destroy
    redirect_to users_url
  end
end

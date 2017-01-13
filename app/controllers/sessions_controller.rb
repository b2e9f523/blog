class SessionsController < ApplicationController

  def new
    run Session::SignIn
    render Session::Cell::SignIn
  end

  def create
    run Session::SignIn do |op|
      tyrant.sign_in!(op.model)
      flash[:notice] = "Hey mate, welcome back!"
      return redirect_to "/posts"
    end
    render Session::Cell::SignIn, model: @form
  end

  def sign_out
    run Session::SignOut do
      tyrant.sign_out!
      flash[:notice] = "See ya!"
      redirect_to "/posts"
    end
  end
end
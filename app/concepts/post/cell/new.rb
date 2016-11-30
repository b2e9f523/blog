module Post::Cell
  class New < Trailblazer::Cell
    include ActionView::RecordIdentifier
    include ActionView::Helpers::FormOptionsHelper
    include Formular::RailsHelper

    def user_name
      @name = tyrant.current_user.content["firstname"]

      if @name == nil
        @name = tyrant.current_user.email
      end
      return @name
    end
  end
end
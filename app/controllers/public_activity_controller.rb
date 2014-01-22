class PublicActivityController < ApplicationController
  def index
    #@activities = PublicActivity::Activity.all
    public_activities = PublicActivity::Activity.all
    respond_to do |format|
      format.html
      format.datatable {
        render json: {
          aaData: public_activities
        },
        include: [
          { owner: { except: [:password] } },
          { trackable: { except: [:password], methods: [:to_s]  } },
        ]
      }
    end
  end
end

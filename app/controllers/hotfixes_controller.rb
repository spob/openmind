class HotfixesController < ApplicationController

  def index
    redirect_to(:action => 'new')
  end

  def new
    @hotfix_number ||= 1
    @products = Product.active.with_svn_path.by_name
  end

  def create
    redirect_to hotfix_path(:id => params[:hotfix_number], :insight_version => params[:insight_version], :release_number => params[:release_number], :product_id => params[:product_id], :defect => params[:defect])
  end

  def show
    @hotfix_number = params[:id]
    @defect = params[:defect]
    @release_number = params[:release_number]
    @product = Product.find(params[:product_id])
    @insight_version = params[:insight_version]
  end
end

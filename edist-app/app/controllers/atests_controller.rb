class AtestsController < ApplicationController
  # GET /atests
  # GET /atests.xml
  def index
    @atests = Atest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @atests }
    end
  end

  # GET /atests/1
  # GET /atests/1.xml
  def show
    @atest = Atest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @atest }
    end
  end

  # GET /atests/new
  # GET /atests/new.xml
  def new
    @atest = Atest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @atest }
    end
  end

  # GET /atests/1/edit
  def edit
    @atest = Atest.find(params[:id])
  end

  # POST /atests
  # POST /atests.xml
  def create
    @atest = Atest.new(params[:atest])

    respond_to do |format|
      if @atest.save
        flash[:notice] = 'Atest was successfully created.'
        format.html { redirect_to(@atest) }
        format.xml  { render :xml => @atest, :status => :created, :location => @atest }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @atest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /atests/1
  # PUT /atests/1.xml
  def update
    @atest = Atest.find(params[:id])

    respond_to do |format|
      if @atest.update_attributes(params[:atest])
        flash[:notice] = 'Atest was successfully updated.'
        format.html { redirect_to(@atest) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @atest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /atests/1
  # DELETE /atests/1.xml
  def destroy
    @atest = Atest.find(params[:id])
    @atest.destroy

    respond_to do |format|
      format.html { redirect_to(atests_url) }
      format.xml  { head :ok }
    end
  end
end

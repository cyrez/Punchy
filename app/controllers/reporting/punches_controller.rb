class Reporting::PunchesController < ApplicationController
	
###############################################
# Punchy
# Please submit bug reports/suggestions via the github repo http://github.com/mazondo/Punchy
# 
# Copyright (c) 2010 Ryan Quinn
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
################################################ 

  # GET /punches
  # GET /punches.xml
  def index
  	@reporting = true
    @punches = Punch
    #if params[:from]
    #	@punches = @punches.where("created_at > ?", params[:from])
	  #end
	  #if params[:to]
  	#	@punches2 = @punches.where("created_at < ?", params[:to])
  	#end
  	if params[:from_year]
  	  from_month = params[:from_month] || 1
  	  to_month = params[:to_month] || 12
  	  if params[:to_year]
  	    @punches = @punches.between(Time.new(params[:from_year],from_month).beginning_of_month, Time.new(params[:to_year],to_month).end_of_month)
  	  elsif params[:from_month]
  	    @punches = @punches.in_month(Time.new(params[:from_year],params[:from_month]))
  	  else
  	    @punches = @punches.in_year(Time.new(params[:from_year]))
  	  end
  	end
    if params[:act]
      @punches = @punches.tagged_with(params[:act], :as => :action)
  	end
  	if params[:client]
  		@punches = @punches.tagged_with(params[:client], :as => :client)
  	end
  	if params[:project]
  		@punches = @punches.tagged_with(params[:project], :as => :project)
  	end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @punches }
      format.csv do
        render_csv("#{params[:from_year]}_#{params[:from_month]}_stunden")
      end
    end
  end
  
  private
  
  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain" 
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end

    render :layout => false
  end

 # # GET /punches/1
 # # GET /punches/1.xml
 # def show
 #   @punch = Punch.find(params[:id])
 #
 #   respond_to do |format|
 #     format.html # show.html.erb
 #     format.xml  { render :xml => @punch }
 #   end
 # end
 #
 # # GET /punches/new
 # # GET /punches/new.xml
 # def new
 #   @punch = Punch.new
 #
 #   respond_to do |format|
 #     format.html # new.html.erb
 #     format.xml  { render :xml => @punch }
 #   end
 # end
 #
 # # GET /punches/1/edit
 # def edit
 #   @punch = Punch.find(params[:id])
 # end
 #
 # # POST /punches
 # # POST /punches.xml
 # def create
 #   @punch = Punch.new(params[:punch])
 #
 #   respond_to do |format|
 #     if @punch.parse_and_save
 #       format.html { redirect_to(punches_path, :notice => 'Punch was successfully created.') }
 #       format.xml  { render :xml => @punch, :status => :created, :location => @punch }
 #     else
 #       format.html { render :action => "new" }
 #       format.xml  { render :xml => @punch.errors, :status => :unprocessable_entity }
 #     end
 #   end
 # end
 #
 # # PUT /punches/1
 # # PUT /punches/1.xml
 # def update
 #   @punch = Punch.find(params[:id])
 #   @punch.attributes = params[:punch]
 #
 #   respond_to do |format|
 #     if @punch.parse_and_save
 #       format.html { redirect_to(punches_path, :notice => 'Punch was successfully updated.') }
 #       format.xml  { head :ok }
 #     else
 #       format.html { render :action => "edit" }
 #       format.xml  { render :xml => @punch.errors, :status => :unprocessable_entity }
 #     end
 #   end
 # end
 #
 # # DELETE /punches/1
 # # DELETE /punches/1.xml
 # def destroy
 #   @punch = Punch.find(params[:id])
 #   @punch.destroy
 #
 #   respond_to do |format|
 #     format.html { redirect_to(punches_url) }
 #     format.xml  { head :ok }
 #   end
 # end
 # 
 # #this is the json function for the autocomplete
 # def autocomplete
 # 	@tags = nil
 # 	unless params[:term].blank?
 # 		case params[:term].first
 # 	when "\#"
 # 		term = params[:term].gsub("\#", "")
 # 		@tags = Punch.project_counts.where("tags.name like ?", "%#{term}%").collect! {|p| "\#" + p.name}
 # 	when "@"
 # 		term = params[:term].gsub("@", "")
 # 		@tags = Punch.client_counts.where("tags.name like ?", "%#{term}%").collect! {|c| "@" + c.name}
 # 	when "*"
 # 		term = params[:term].gsub("*", "")
 # 		@tags = Punch.action_counts.where("tags.name like ?", "%#{term}%").collect! {|a| "*" + a.name}
 # 	else
 # 		term = params[:term]
 #   	@tags = Punch.project_counts.where("tags.name like ?", "%#{term}%").collect! {|p| "\#" + p.name}
 #   	@tags << Punch.action_counts.where("tags.name like ?", "%#{term}%").collect! {|a| "*" + a.name}
 #   	@tags << Punch.client_counts.where("tags.name like ?", "%#{term}%").collect! {|c| "@" + c.name}
 # 		end
 # 		@tags.flatten!
 # 	end
 # 	respond_to do |format|
 # 		format.js { render :json => @tags}
 # 	end
 # end
end

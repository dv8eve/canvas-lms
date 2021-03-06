#
# Copyright (C) 2013 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/../api_spec_helper')

include Api::V1::Conferences
include Api::V1::Json
include Api

describe "Conferences API", :type => :integration do
  before do
    # these specs need an enabled web conference plugin
    @plugin = PluginSetting.find_or_create_by_name('wimba')
    @plugin.update_attribute(:settings, { :domain => 'wimba.test' })
    @category_path_options = { :controller => "conferences", :format => "json" }
  end

  describe "GET list of conferences" do

    it "should require authorization" do
      course_with_teacher(:active_all => true)
      @user = nil
      raw_api_call(:get, "/api/v1/courses/#{@course.to_param}/conferences", @category_path_options.
        merge(action: 'index', course_id: @course.to_param))
      response.code.should == '401'
    end

    it "should list all the conferences" do
      course_with_teacher(:active_all => true)
      @conferences = (1..2).map { |i| @course.web_conferences.create!(:conference_type => 'Wimba',
                                                                      :duration => 60,
                                                                      :user => @teacher,
                                                                      :title => "Wimba #{i}")}

      json = api_call(:get, "/api/v1/courses/#{@course.to_param}/conferences", @category_path_options.
        merge(action: 'index', course_id: @course.to_param))
      json.should == api_conferences_json(@conferences.reverse.map{|c| WebConference.find(c.id)}, @course, @user)
    end

    it "should not list conferences for disabled plugins" do
      course_with_teacher(:active_all => true)
      plugin = PluginSetting.find_or_create_by_name('adobe_connect')
      plugin.update_attribute(:settings, { :domain => 'adobe_connect.test' })
      @conferences = ['AdobeConnect', 'Wimba'].map {|ct| @course.web_conferences.create!(:conference_type => ct,
                                                                                         :duration => 60,
                                                                                         :user => @teacher,
                                                                                         :title => ct)}
      plugin.disabled = true
      plugin.save!
      json = api_call(:get, "/api/v1/courses/#{@course.to_param}/conferences", @category_path_options.
        merge(action: 'index', course_id: @course.to_param))
      json.should == api_conferences_json([WebConference.find(@conferences[1].id)], @course, @user)
    end

    it "should only list conferences the user is a participant of" do
      course_with_student(:active_all => true)
      @conferences = (1..2).map { |i| @course.web_conferences.create!(:conference_type => 'Wimba',
                                                                      :duration => 60,
                                                                      :user => @teacher,
                                                                      :title => "Wimba #{i}")}
      @conferences[0].users << @user
      @conferences[0].save!
      json = api_call(:get, "/api/v1/courses/#{@course.to_param}/conferences", @category_path_options.
        merge(action: 'index', course_id: @course.to_param))
      json.should == api_conferences_json([WebConference.find(@conferences[0].id)], @course, @user)
    end

    it 'should get a conferences for a group' do
      course_with_student(:active_all => true)
      @group = @course.groups.create!(:name => "My Group")
      @group.add_user(@student, 'accepted', true)
      @conferences = (1..2).map { |i| @group.web_conferences.create!(:conference_type => 'Wimba',
                                                                      :duration => 60,
                                                                      :user => @teacher,
                                                                      :title => "Wimba #{i}")}
      json = api_call(:get, "/api/v1/groups/#{@group.to_param}/conferences", @category_path_options.
        merge(action: 'index', group_id: @group.to_param))
      json.should == api_conferences_json(@conferences.reverse.map{|c| WebConference.find(c.id)}, @group, @student)
    end

  end
end
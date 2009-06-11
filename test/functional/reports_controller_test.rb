require File.dirname(__FILE__) + '/../test_helper'

class ReportsControllerTest < ActionController::TestCase
  fixtures :users, :companies, :tasks, :customers
  
  def setup
    @request.with_subdomain('cit')
    @user = users(:admin)
    @request.session[:user_id] = @user.id
  end

  test "list should render" do
    get :list
    assert_response :success
  end

  test "pivot report should render" do
    assert_report_works(WorklogReport::PIVOT)
  end

  test "audit report should render" do
    assert_report_works(WorklogReport::AUDIT)
  end

  test "timesheet report should render" do
    assert_report_works(WorklogReport::TIMESHEET)
  end

  test "workload report should render" do
    assert_report_works(WorklogReport::WORKLOAD)
  end

  private

  def assert_report_works(type)
    t1 = Task.first
    t1.update_attributes(:duration => 1000)
    log = t1.work_logs.build(:started_at => Time.now, :duration => 60,
                             :company => @user.company, :user => @user,
                             :customer => @user.company.customers.first,
                             :project => t1.project)
    log.save!


    post :list, :report => {
      :type => type,
      :range => 0
    }
    assert_response :success
    worklogs = assigns["logs"]
    assert worklogs.any?
    if type != WorklogReport::WORKLOAD
      assert worklogs.include?(log)
    end
  end
end

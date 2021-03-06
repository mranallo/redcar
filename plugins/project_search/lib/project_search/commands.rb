
class ProjectSearch
  class RefreshIndex < Redcar::Command
    sensitize :open_project
    
    def execute
      if project = Redcar::Project::Manager.focussed_project
        if index = ProjectSearch.indexes[project.path]
          index.delete
          project.refresh
        end
      end
    end
  end
  
  class WordSearchCommand < Redcar::Command
    sensitize :open_project
    
    def find_open_instance
      all_tabs = Redcar.app.focussed_window.notebooks.map { |nb| nb.tabs }.flatten
      all_tabs.find do |t|
        t.is_a?(Redcar::HtmlTab) && t.title == ProjectSearch::WordSearchController::TITLE
      end
    end
    
    def execute
      if project = Redcar::Project::Manager.focussed_project
        if tab = find_open_instance
          tab.html_view.refresh
          tab.focus
        else
          index = ProjectSearch.indexes[project.path]
          if index and index.has_content?
            tab = win.new_tab(Redcar::HtmlTab)
            tab.html_view.controller = ProjectSearch::WordSearchController.new
            tab.focus
          else
            Redcar::Application::Dialog.message_box("Your project is still being indexed.", :type => :error)
          end
        end
      else
        Redcar::Application::Dialog.message_box("You need an open project to be able to use Find In Project!", :type => :error)
      end
      return
    end
  end
end



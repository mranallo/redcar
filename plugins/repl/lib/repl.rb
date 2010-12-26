require 'repl/repl_mirror'
require 'repl/repl_tab'

module Redcar
  class REPL
    def self.menus
      Menu::Builder.build do
        sub_menu "Plugins" do
          sub_menu "REPL", :priority => 180 do
            item "Execute", REPL::CommitREPL
            item "Clear History", REPL::ClearHistoryREPL
          end
        end
      end
    end

    def self.keymaps
      osx = Keymap.build("main", :osx) do
        link "Cmd+M", REPL::CommitREPL
      end

      linwin = Keymap.build("main", [:linux, :windows]) do
        link "Ctrl+M", REPL::CommitREPL
      end

      [linwin, osx]
    end

    def self.sensitivities
      [
        Sensitivity.new(:open_repl_tab, Redcar.app, false, [:tab_focussed]) do |tab|
          tab and
          tab.is_a?(REPL::ReplTab) and
          tab.edit_view.document.mirror.is_a?(REPL::ReplMirror)
        end
      ]
    end

    class OpenREPL < Command

      def open_repl(mirror)
        tab = win.new_tab(REPL::ReplTab)
        tab.repl_mirror = mirror
        tab.focus
      end
    end

    class ReplCommand < Command
      sensitize :open_repl_tab
    end

    class CommitREPL < ReplCommand

      def execute
        edit_view = win.focussed_notebook.focussed_tab.edit_view
        edit_view.document.save!
      end
    end

    class ClearHistoryREPL < ReplCommand

      def execute
        mirror = win.focussed_notebook.focussed_tab.edit_view.document.mirror
        mirror.clear_history
      end
    end
  end
end
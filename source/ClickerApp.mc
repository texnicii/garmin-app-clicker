import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ClickerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var view = new ClickerView();
        return [ view, new ClickerDelegate(view) ];
    }
}

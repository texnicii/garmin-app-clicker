import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ClickerView extends WatchUi.View {

    private const STORAGE_KEY = "count";
    private var _count as Number = 0;

    function initialize() {
        View.initialize();
        var stored = Application.Storage.getValue(STORAGE_KEY);
        if (stored instanceof Number) {
            _count = stored;
        }
    }

    function getCount() as Number {
        return _count;
    }

    function increment() as Void {
        _count += 1;
        persist();
        WatchUi.requestUpdate();
    }

    function reset() as Void {
        _count = 0;
        persist();
        WatchUi.requestUpdate();
    }

    private function persist() as Void {
        Application.Storage.setValue(STORAGE_KEY, _count);
    }

    // Marker colours (24-bit RGB; works on all API levels).
    private const COLOR_PLUS  = 0x78C8FF;  // sky blue   -> +1 button
    private const COLOR_RESET = 0xFFAA78;  // soft amber -> reset button

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // The counter, centered and large.
        dc.drawText(
            w / 2,
            h / 2,
            Graphics.FONT_NUMBER_THAI_HOT,
            _count.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // On touch watches without a left button the reset is a screen
        // long-press, so we swap the hint and drop the left-pointing arrow.
        var touchReset = Capabilities.usesTouchReset();
        var hint = touchReset ? Rez.Strings.ResetHintTouch : Rez.Strings.ResetHint;

        // Hint for the reset gesture.
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            w / 2,
            h - (h / 8),
            Graphics.FONT_XTINY,
            WatchUi.loadResource(hint) as String,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // "+1" marker always points at the main START/SELECT button.
        drawPlusMarker(dc, w, h);

        // The left "0" arrow only makes sense when reset is a physical button.
        if (!touchReset) {
            drawResetMarker(dc, w, h);
        }
    }

    // "+1 >" near the right edge at ~2 o'clock — points at START/SELECT.
    private function drawPlusMarker(dc as Graphics.Dc, w as Number, h as Number) as Void {
        var mx = (w * 0.84).toNumber();
        var my = (h * 0.31).toNumber();
        dc.setColor(COLOR_PLUS, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            mx - 4, my,
            Graphics.FONT_XTINY,
            "+1",
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.fillPolygon([
            [mx + 8, my],
            [mx,     my - 5],
            [mx,     my + 5]
        ]);
    }

    // "< 0" near the left edge at ~9 o'clock — points at UP/MENU (long-press = reset).
    private function drawResetMarker(dc as Graphics.Dc, w as Number, h as Number) as Void {
        var mx = (w * 0.10).toNumber();
        var my = (h * 0.50).toNumber();
        dc.setColor(COLOR_RESET, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [mx - 8, my],
            [mx,     my - 5],
            [mx,     my + 5]
        ]);
        dc.drawText(
            mx + 4, my,
            Graphics.FONT_XTINY,
            "0",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

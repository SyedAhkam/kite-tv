package world.syed.kite_tv

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView

class MainActivity : AppCompatActivity() {
    private lateinit var webview: WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        webview = findViewById(R.id.webview)

        var webSettings = webview.getSettings();
        webSettings.setJavaScriptEnabled(true);

        webview.loadUrl("https://syed.world");
    }
}

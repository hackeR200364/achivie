package com.achivie.achivie

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class  ReportsContainerAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory{

    override fun createNativeAd(
            nativeAd: NativeAd,
            customOptions: MutableMap<String, Any>?
    ): NativeAdView {

        val nativeAdView = LayoutInflater.from(context)
                .inflate(R.layout.report_container_native_ad, null) as NativeAdView

        with(nativeAdView) {
            val attributionViewSmall =
                    findViewById<TextView>(R.id.tv_report_container_native_ad_attribution_small)

            val attributionViewLarge =
                    findViewById<TextView>(R.id.tv_report_container_native_ad_attribution_large)

            val iconView = findViewById<ImageView>(R.id.iv_report_container_native_ad_icon)
            val icon = nativeAd.icon

            if (icon != null && iconView != null) {
                attributionViewSmall?.visibility = View.INVISIBLE
                attributionViewLarge?.visibility = View.VISIBLE
                iconView.setImageDrawable(icon.drawable)
            } else {
                attributionViewSmall?.visibility = View.VISIBLE
                attributionViewLarge?.visibility = View.INVISIBLE
            }



            this.iconView = iconView

            val headlineView = findViewById<TextView>(R.id.tv_report_container_native_ad_title1)
            headlineView.text = nativeAd.headline
            this.headlineView = headlineView

            val advertiserView = findViewById<TextView>(R.id.tv_report_container_native_ad_advertiser)
            advertiserView.text = nativeAd.advertiser
            this.advertiserView = advertiserView

            val seeDetailsBtn = findViewById<Button>(R.id.btn_report_container_native_ad_see_details)
            seeDetailsBtn.text = nativeAd.price

            val storeView = findViewById<TextView>(R.id.tv_report_container_native_ad_store)
            storeView.text = nativeAd.store
            this.storeView = storeView

            val ratingView = findViewById<TextView>(R.id.tv_report_container_native_ad_rating_points)
            ratingView.text = nativeAd.starRating.toString()

            val bodyView = findViewById<TextView>(R.id.tv_report_container_native_ad_title2)
            bodyView.text = nativeAd.body
            visibility = if (nativeAd.body!!.isNotEmpty()) View.VISIBLE else View.INVISIBLE
            this.bodyView = bodyView

            setNativeAd(nativeAd)
        }
        return  nativeAdView
    }
}
#
# Copyright (C) 2021 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Restrict the visibility of Android.bp files to improve build analysis time
$(call inherit-product-if-exists, vendor/google/products/sources_pixel.mk)

ifdef RELEASE_GOOGLE_HUSKY_RADIO_DIR
RELEASE_GOOGLE_PRODUCT_RADIO_DIR := $(RELEASE_GOOGLE_HUSKY_RADIO_DIR)
endif
ifdef RELEASE_GOOGLE_HUSKY_RADIOCFG_DIR
RELEASE_GOOGLE_PRODUCT_RADIOCFG_DIR := $(RELEASE_GOOGLE_HUSKY_RADIOCFG_DIR)
endif
RELEASE_GOOGLE_BOOTLOADER_HUSKY_DIR ?= pdk# Keep this for pdk TODO: b/327119000
RELEASE_GOOGLE_PRODUCT_BOOTLOADER_DIR := bootloader/$(RELEASE_GOOGLE_BOOTLOADER_HUSKY_DIR)
$(call soong_config_set,shusky_bootloader,prebuilt_dir,$(RELEASE_GOOGLE_BOOTLOADER_HUSKY_DIR))


TARGET_LINUX_KERNEL_VERSION := $(RELEASE_KERNEL_HUSKY_VERSION)
# Keeps flexibility for kasan and ufs builds
TARGET_KERNEL_DIR ?= $(RELEASE_KERNEL_HUSKY_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_KERNEL_HUSKY_DIR)/kernel-headers

LOCAL_PATH := device/google/shusky

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
    USE_UWBFIELDTESTQM := true
endif
ifeq ($(filter factory_husky, $(TARGET_PRODUCT)),)
    include device/google/shusky/uwb/uwb_calibration.mk
endif

ifneq ($(TARGET_BOOTS_16K),true)
PRODUCT_16K_DEVELOPER_OPTION := $(RELEASE_GOOGLE_HUSKY_16K_DEVELOPER_OPTION)
endif

$(call inherit-product-if-exists, vendor/google_devices/shusky/prebuilts/device-vendor-husky.mk)
$(call inherit-product-if-exists, vendor/google_devices/zuma/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/zuma/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/shusky/proprietary/husky/device-vendor-husky.mk)
$(call inherit-product-if-exists, vendor/google_devices/husky/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/qorvo/uwb/qm35-hal/Device.mk)
$(call inherit-product-if-exists, vendor/google_devices/shusky/proprietary/WallpapersHusky.mk)

# display

CAMERA_PRODUCT ?= husky

ifeq ($(RELEASE_PIXEL_AIDL_AUDIO_HAL_ZUMA),true)
USE_AUDIO_HAL_AIDL := true
endif

include device/google/shusky/camera/camera.mk
include device/google/shusky/audio/husky/audio-tables.mk
include device/google/zuma/device-shipping-common.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/stm/predump_stm20.mk
include device/google/gs-common/touch/gti/predump_gti.mk
include device/google/gs-common/touch/touchinspector/touchinspector.mk

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/shusky/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.husky.rc

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element-service.thales

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \

ifeq ($(USE_AUDIO_HAL_AIDL),true)
# AIDL

else
# HIDL

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio

# Sound Dose
PRODUCT_PACKAGES += \
	android.hardware.audio.sounddose-vendor-impl \
	audio_sounddose_aoc

endif

# Bluetooth hci_inject test tool
PRODUCT_PACKAGES_DEBUG += \
    hci_inject

# Bluetooth SAR test tool
PRODUCT_PACKAGES_DEBUG += \
    sar_test

# Bluetooth EWP test tool
PRODUCT_PACKAGES_DEBUG += \
    ewp_tool

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio \
	librondo

# PowerStats HAL
PRODUCT_SOONG_NAMESPACES += \
    device/google/shusky

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/shusky/prebuilts

# UWB
PRODUCT_SOONG_NAMESPACES += \
    device/google/shusky/uwb

# Location
# SDK build system
include device/google/gs-common/gps/brcm/device.mk

# Set zram size
PRODUCT_VENDOR_PROPERTIES += \
	vendor.zram.size=50p \
	persist.device_config.configuration.disable_rescue_party=true

# Fingerprint HAL
GOODIX_CONFIG_BUILD_VERSION := g7_trusty
APEX_FPS_TA_DIR := //vendor/google_devices/shusky/prebuilts
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_common.mk)
ifeq ($(filter factory%, $(TARGET_PRODUCT)),)
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_shipping.mk)
else
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_factory.mk)
endif

# Vibrator HAL
$(call soong_config_set,haptics,kernel_ver,v$(subst .,_,$(TARGET_LINUX_KERNEL_VERSION)))
ACTUATOR_MODEL := luxshare_ict_081545
ADAPTIVE_HAPTICS_FEATURE := adaptive_haptics_v1

# Set device family property for SMR
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.device_family=HK3SB3AK3

# Set build properties for SMR builds
ifeq ($(RELEASE_IS_SMR), true)
    ifneq (,$(RELEASE_BASE_OS_HUSKY))
        PRODUCT_BASE_OS := $(RELEASE_BASE_OS_HUSKY)
    endif
endif

# Set build properties for EMR builds
ifeq ($(RELEASE_IS_EMR), true)
    ifneq (,$(RELEASE_BASE_OS_HUSKY))
        PRODUCT_PROPERTY_OVERRIDES += \
        ro.build.version.emergency_base_os=$(RELEASE_BASE_OS_HUSKY)
    endif
endif

# Window Extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

PRODUCT_PACKAGES += \
    NoCutoutOverlay \
    AvoidAppsInCutoutOverlay

# ETM
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif

PRODUCT_NO_BIONIC_PAGE_SIZE_MACRO := true

ifneq ($(wildcard vendor/arm/mali/valhall),)
PRODUCT_CHECK_PREBUILT_MAX_PAGE_SIZE := true
endif

PRODUCT_PACKAGES += fir-proximity-feature.xml

<template>
  <n-card
    :segmented="{
      content: true,
      footer: 'soft',
    }"
  >
    <PDFSelection
      @update:pdfInfo="(info) => (pdfInfo = info)"
      :noFileError="noFileError"
      style="
        width: 100%;
        padding-bottom: 10px;
        margin-bottom: 10px;
        border-bottom: 1px solid var(--n-border-color);
      "
    />

    <!-- Scan Settings -->
    <n-space :size="40" style="margin-bottom: 10px">
      <ColorspaceSetting v-model:colorspace="config.colorspace" />
      <BorderSetting v-model:border="config.border" />
    </n-space>

    <RotateSetting v-model:rotate="config.rotate" />
    <RotateVarianceSetting v-model:rotate_var="config.rotate_var" />
    <BlurSetting v-model:blur="config.blur" />
    <AttenuateSetting v-model:attenuate="config.attenuate" />

    <template #footer>
      <n-space vertical :wrap-item="false">
        <PDFPageSelection v-model:page="page" :pdfInstance="pdfInstance" />
        <ActionButtons
          @action:preview="$emit('action:preview')"
          @action:generate="generateAction"
        />
        <GenerateStatus
          v-if="status != 'not-started'"
          :status="status"
          :text="statusText"
        />
      </n-space>
    </template>
  </n-card>
</template>

<script lang="ts" setup>
import { NCard, NSpace, useMessage } from "naive-ui";

import PDFSelection from "./PDFSelection.vue";

import BorderSetting from "./Settings/BorderSetting.vue";
import RotateSetting from "./Settings/RotateSetting.vue";
import RotateVarianceSetting from "./Settings/RotateVarianceSetting.vue";
import ColorspaceSetting from "./Settings/ColorspaceSetting.vue";
import BlurSetting from "./Settings/BlurSetting.vue";
import AttenuateSetting from "./Settings/AttenuateSetting.vue";

import ActionButtons from "./ActionButtons.vue";
import PDFPageSelection from "./PDFPageSelection.vue";
import GenerateStatus from "./GenerateStatus.vue";

import type { ScanConfig } from "@/utils/scan";
import { ref, watch, computed } from "vue";

import { GenerateScannedPDFSetup } from "./GenerateScannedPDFSetup";

import type { PDF, PDFInfoType } from "@/utils/pdf";
import type { Scan } from "@/utils/scan";
import { useI18n } from "vue-i18n";

const { t } = useI18n();
const message = useMessage();

// Handle pdfSource changes
const pdfInfo = ref({
  source: "",
  filename: "",
} as PDFInfoType);
const page = ref(1);
const noFileError = ref(false);

const props = defineProps<{
  config: ScanConfig;
  pdfInstance: PDF;
  scanInstance: Scan;
}>();

const emit = defineEmits<{
  (e: "update:pdfInfo", info: PDFInfoType): void;
  (e: "update:config", config: ScanConfig): void;
  (e: "update:page", page: number): void;
  (e: "action:preview"): void;
  (e: "action:generate"): void;
}>();

watch(pdfInfo, (info) => {
  if (info) {
    noFileError.value = false;
    emit("update:pdfInfo", info);
  }
});

watch(page, (new_page) => {
  if (new_page) {
    emit("update:page", new_page);
  }
});

const config = computed({
  get: () => props.config,
  set: (config) => emit("update:config", config),
});

const { statusText, downloadScannedPDF, status } = GenerateScannedPDFSetup();

function generateAction() {
  if (pdfInfo.value.source) {
    noFileError.value = false;
    downloadScannedPDF(props.scanInstance);
  } else {
    noFileError.value = true;
    message.error(t("settings.pdfNoSelectMessage"));
  }
}
</script>

/**
 * Form Wizard Composable Template
 * 
 * Multi-step form state management.
 * Handles step navigation, validation, and draft auto-save.
 * 
 * Follows: ui-rules.md (form page pattern)
 */

import { ref, computed, watch } from 'vue';

export interface FormStep {
  key: string;
  label: string;
  isValid: boolean;
}

export function useFormWizard(steps: FormStep[], options?: {
  autoSaveKey?: string;  // localStorage key for draft
  autoSaveInterval?: number; // ms
}) {
  const currentStepIndex = ref(0);
  const isSubmitting = ref(false);
  const draftSavedAt = ref<string | null>(null);

  const currentStep = computed(() => steps[currentStepIndex.value]);
  const isFirstStep = computed(() => currentStepIndex.value === 0);
  const isLastStep = computed(() => currentStepIndex.value === steps.length - 1);
  const canProceed = computed(() => currentStep.value.isValid);
  const progress = computed(() => ((currentStepIndex.value + 1) / steps.length) * 100);

  function nextStep() {
    if (!isLastStep.value && canProceed.value) {
      currentStepIndex.value++;
    }
  }

  function prevStep() {
    if (!isFirstStep.value) {
      currentStepIndex.value--;
    }
  }

  function goToStep(index: number) {
    if (index >= 0 && index < steps.length) {
      currentStepIndex.value = index;
    }
  }

  function goToStepByKey(key: string) {
    const index = steps.findIndex(s => s.key === key);
    if (index !== -1) currentStepIndex.value = index;
  }

  // ─── Draft Auto-Save ─────────────────────────────────────────

  function saveDraft(data: Record<string, unknown>) {
    if (!options?.autoSaveKey) return;
    try {
      localStorage.setItem(options.autoSaveKey, JSON.stringify({
        data,
        step: currentStepIndex.value,
        savedAt: new Date().toISOString(),
      }));
      draftSavedAt.value = new Date().toISOString();
    } catch {
      // localStorage full or unavailable
    }
  }

  function loadDraft<T>(): { data: T; step: number } | null {
    if (!options?.autoSaveKey) return null;
    try {
      const raw = localStorage.getItem(options.autoSaveKey);
      if (!raw) return null;
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  function clearDraft() {
    if (!options?.autoSaveKey) return;
    localStorage.removeItem(options.autoSaveKey);
    draftSavedAt.value = null;
  }

  // ─── Auto-save watcher ───────────────────────────────────────

  let autoSaveTimer: ReturnType<typeof setTimeout> | null = null;

  function setupAutoSave(getData: () => Record<string, unknown>) {
    if (!options?.autoSaveKey) return;

    watch(currentStepIndex, () => {
      if (autoSaveTimer) clearTimeout(autoSaveTimer);
      autoSaveTimer = setTimeout(() => {
        saveDraft(getData());
      }, options?.autoSaveInterval || 2000);
    });
  }

  return {
    // State
    currentStepIndex,
    currentStep,
    isFirstStep,
    isLastStep,
    canProceed,
    progress,
    isSubmitting,
    draftSavedAt,

    // Navigation
    nextStep,
    prevStep,
    goToStep,
    goToStepByKey,

    // Draft
    saveDraft,
    loadDraft,
    clearDraft,
    setupAutoSave,
  };
}

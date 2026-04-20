#include <jni.h>

#include "gsa_core.h"

extern "C" JNIEXPORT jint JNICALL
Java_com_gsa_nativebridge_GsaNativeBridge_canSubmitExam(JNIEnv*, jclass, jint answered, jint total) {
  return gsa_can_submit_exam(answered, total);
}

extern "C" JNIEXPORT jint JNICALL
Java_com_gsa_nativebridge_GsaNativeBridge_scorePercent(JNIEnv*, jclass, jint correct, jint total) {
  return gsa_score_percent(correct, total);
}

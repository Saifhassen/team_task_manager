<<<<<<< HEAD
=======
plugins {
    id("com.android.application") version "8.7.0" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false // ✅ Firebase plugin إذا كنت تستخدم Firebase
}

>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

<<<<<<< HEAD
=======
// ✅ تغيير مكان مجلد البناء (اختياري حسب الحاجة)
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
<<<<<<< HEAD
=======

// ✅ التأكد من ترتيب تقييم المشاريع الفرعية
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c
subprojects {
    project.evaluationDependsOn(":app")
}

<<<<<<< HEAD
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15' // مطلوب لـ Firebase
    }
}

=======
// ✅ مهمة التنظيف
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c

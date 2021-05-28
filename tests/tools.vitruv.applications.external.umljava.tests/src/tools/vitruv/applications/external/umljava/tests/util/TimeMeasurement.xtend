package tools.vitruv.applications.external.umljava.tests.util

import java.util.HashMap
import com.google.common.base.Stopwatch
import java.nio.file.Path
import java.util.concurrent.TimeUnit
import java.nio.file.Files
import java.nio.file.StandardOpenOption
import java.io.IOException
import org.junit.jupiter.api.TestInfo

class TimeMeasurement {
    public static val shared = new TimeMeasurement()

    var String activeClass
    var TestInfo activeTest
    var HashMap<String, Stopwatch> times = new HashMap()

    def startTest(TestInfo testInfo, String activeClass) {
        activeTest = testInfo
        this.activeClass = activeClass
    }

    def addStopwatchForKey(Stopwatch stopwatch, String key) {
        times.put(key, stopwatch)
    }

    def stopAndLogActiveTest() {
        val path = Path.of("/Users/janwittler/Documents/Studium/Master/Masterarbeit/Timing")
        if (activeTest !== null) {
            val classParts = activeClass.split("\\.")
            val className = classParts.last
            var suiteName = classParts.get(classParts.size - 2)
            var testName = activeTest.displayName.replace("()", "")
            if (testName == "Model" || testName == "Model_noAssociations") {
                if (testName == "Model_noAssociations") {
                    suiteName += "_noAssociations"
                }
                testName = activeTest.testMethod.get.name.split("\\.").last.replace("(java.lang.String)", "")
            }
            val classPath = path.resolve(suiteName).resolve(className)
            if (!classPath.toFile().exists) {
                classPath.toFile().mkdirs()
            }
            val filePath = classPath.resolve(testName + ".csv")
            var text = "\n"
            if (!filePath.toFile().exists) {
                filePath.toFile().createNewFile
                text = ""
            }

            text += #["derivation", "overall"].map[ key |
                val stopwatch = this.times.get(key)
                return stopwatch.elapsed(TimeUnit.NANOSECONDS).toString
            ].join(";")
            try {
                Files.write(filePath, text.getBytes(), StandardOpenOption.APPEND);
            } catch (IOException e) {
            //exception handling left as an exercise for the reader
            }
        }
        activeTest = null
        activeClass = null
        times.clear()
    }
}
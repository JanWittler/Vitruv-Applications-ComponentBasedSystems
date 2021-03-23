package tools.vitruv.applications.external.umljava.tests.util

import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import org.apache.commons.io.FilenameUtils

class JavaFileComparisonHelper implements FileComparisonHelper {
    /** Accepts files if they all have the file extension "java". */
    override canCompareFiles(File[] files) {
        files.forall [ FilenameUtils.getExtension(path) == "java" ]
    }

    /**
     * Compares two java files.
     * The comparison compares each line of the files for equality, leading or trailing whitespaces are ignored.
     * Empty lines are ignored.
     * Spaces before semicolon are ignored.
     * Lines starting with an import statement are ignored as imports are currently not cleaned up by the consistency mechanism.
     */
    override areFilesSemanticallyIdentical(File expected, File actual) {
        val readerExpected = new BufferedReader(new FileReader(expected))
        val readerActual = new BufferedReader(new FileReader(actual))

        var lineExpected = readerExpected.readLineTrimmed
        var lineActual = readerActual.readLineTrimmed
        while (lineExpected !== null || lineActual !== null) {
            if (lineExpected !== null && (lineExpected.startsWith("import") || lineExpected.empty)) {
                lineExpected = readerExpected.readLineTrimmed
            } else if (lineActual !== null && (lineActual.startsWith("import") || lineActual.empty)) {
                lineActual = readerActual.readLineTrimmed
            } else {
                if (lineExpected != lineActual) {
                    return false
                }
                lineExpected = readerExpected.readLineTrimmed
                lineActual = readerActual.readLineTrimmed
            }
        }
        return true
    }

    private static def readLineTrimmed(BufferedReader reader) {
        reader.readLine?.trim?.replace(" ;", ";")
    }
}
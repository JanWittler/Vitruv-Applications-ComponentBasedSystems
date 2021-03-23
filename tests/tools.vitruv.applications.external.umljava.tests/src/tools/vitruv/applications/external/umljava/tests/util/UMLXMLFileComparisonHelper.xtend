package tools.vitruv.applications.external.umljava.tests.util

import java.io.File
import java.io.FileInputStream
import java.io.InputStreamReader
import java.util.HashSet
import org.custommonkey.xmlunit.Difference
import org.custommonkey.xmlunit.DifferenceConstants
import org.custommonkey.xmlunit.DifferenceListener
import org.custommonkey.xmlunit.XMLUnit
import org.w3c.dom.Node
import org.xml.sax.InputSource
import org.apache.commons.io.FilenameUtils

import static org.custommonkey.xmlunit.XMLUnit.*

class UMLXMLFileComparisonHelper implements FileComparisonHelper {
    /** Accepts files if they all have the file extension "uml". */
    override canCompareFiles(File[] files) {
        files.forall[FilenameUtils.getExtension(path) == "uml"]
    }

    /**
     * Compares two UML XML files.
     * The comparison allows the absence of various default values, 
     * mostly the type attribute when it can be inferred.
     */
    override areFilesSemanticallyIdentical(File expected, File actual) {
        val expectedStream = new FileInputStream(expected)
        val expectedSource = new InputSource(new InputStreamReader(expectedStream))
        val actualStream = new FileInputStream(actual)
        val actualSource = new InputSource(new InputStreamReader(actualStream))

        XMLUnit.ignoreWhitespace = true
        XMLUnit.ignoreAttributeOrder = true
        val diff = XMLUnit.compareXML(expectedSource, actualSource)
        diff.overrideDifferenceListener(new UMLXMLComparisonDifferenceListener)
        return diff.similar
    }

    private static class UMLXMLComparisonDifferenceListener implements DifferenceListener {
        override differenceFound(Difference difference) {
            if (difference.id === DifferenceConstants.ELEMENT_NUM_ATTRIBUTES_ID) {
                // triggers detailed comparison of missing attributes
                return DifferenceListener.RETURN_IGNORE_DIFFERENCE_NODES_SIMILAR
            } else if (difference.id === DifferenceConstants.ATTR_VALUE_ID) {
                if (difference.controlNodeDetail.node.nodeName == "memberEnd") {
                    val controlMembers = difference.controlNodeDetail.value.split(" ")
                    val testMembers = difference.testNodeDetail.value.split(" ")
                    if (controlMembers.size == testMembers.size &&
                        new HashSet(controlMembers) == new HashSet(testMembers)) {
                        // memberEnd order is arbitrary
                        return DifferenceListener.RETURN_IGNORE_DIFFERENCE_NODES_SIMILAR
                    }
                }
            } else if (difference.id === DifferenceConstants.ATTR_NAME_NOT_FOUND_ID) {
                if (difference.controlNodeDetail.value == "type") {
                    val type = difference.controlNodeDetail.node.attributes.getNamedItem("xmi:type").nodeValue
                    val nodeType = difference.controlNodeDetail.node.nodeName
                    val parentType = difference.controlNodeDetail.node.parentNode?.nodeName
                    if ((type == "uml:PackageImport" && nodeType == "packageImport") ||
                        (type == "uml:Property" && nodeType == "ownedAttribute") ||
                        (type == "uml:Operation" && nodeType == "ownedOperation") ||
                        (type == "uml:Parameter" && nodeType == "ownedParameter") || // annotations
                        (type == "ecore:EAnnotation" && nodeType == "eAnnotations") ||
                        (type == "uml:Property" && nodeType == "ownedEnd") ||
                        (type == "ecore:EStringToStringMapEntry" && nodeType == "details" &&
                            parentType == "eAnnotations") || // generalization
                        (type == "uml:Generalization" && nodeType == "generalization"))
                        return DifferenceListener.RETURN_IGNORE_DIFFERENCE_NODES_SIMILAR
                } else if (difference.controlNodeDetail.value == "visibility") {
                    val controlAttributes = difference.controlNodeDetail.node.attributes
                    val visibility = controlAttributes.getNamedItem("visibility").nodeValue
                    val type = controlAttributes.getNamedItem("xmi:type").nodeValue
                    if (visibility == "public" && type == "uml:Class") {
                        return DifferenceListener.RETURN_IGNORE_DIFFERENCE_NODES_SIMILAR
                    }
                } else if (difference.controlNodeDetail.value == "ecore") {
                    return DifferenceListener.RETURN_IGNORE_DIFFERENCE_NODES_SIMILAR
                }
            }
            return DifferenceListener.RETURN_ACCEPT_DIFFERENCE
        }

        override skippedComparison(Node control, Node test) {
        }
    }
}

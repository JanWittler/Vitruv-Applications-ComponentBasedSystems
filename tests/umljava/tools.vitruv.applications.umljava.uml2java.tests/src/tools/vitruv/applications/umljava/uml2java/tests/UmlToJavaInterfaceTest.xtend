package tools.vitruv.applications.umljava.uml2java.tests

import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList
import org.eclipse.uml2.uml.Interface
import org.junit.After
import org.junit.Before
import org.junit.Ignore
import org.junit.Test
import tools.vitruv.applications.umljava.uml2java.AbstractUmlJavaTest

import static org.junit.Assert.*
import static tools.vitruv.applications.umljava.util.JavaUtil.*
import static tools.vitruv.applications.umljava.util.UmlUtil.*

class UmlToJavaInterfaceTest extends AbstractUmlJavaTest {
    private static val INTERFACE_NAME = "InterfaceName"
    private static val INTERFACE_RENAME = "InterfaceRename"
    private static val SUPERINTERFACENAME_1 = "SuperInterfaceOne"
    private static val SUPERINTERFACENAME_2 = "SuperInterfaceTwo"
    private static val STANDARD_INTERACE_NAME = "StandardInterfaceName"
    private static var Interface uI
    
    
    @Before
    def void before() {
        uI = createSimpleUmlInterface(rootElement, INTERFACE_NAME)
        saveAndSynchronizeChanges(rootElement)
    }
    
    @After
    def void after() {
        if (uI != null) {
            uI.destroy
        }
        saveAndSynchronizeChanges(rootElement)
    }
    
    @Test
    def testCreateInterface() {
        createSimpleUmlInterface(rootElement, STANDARD_INTERACE_NAME);
        saveAndSynchronizeChanges(rootElement)
        assertJavaFileExists(STANDARD_INTERACE_NAME);
    }
    
    @Test
    def testRenameInterface() {
        uI.name = INTERFACE_RENAME;
        saveAndSynchronizeChanges(uI);
        
        assertJavaFileExists(INTERFACE_RENAME);
        assertJavaFileNotExists(INTERFACE_NAME);
    }
    
    @Test
    def testDeleteInterface() {
        uI.destroy;
        saveAndSynchronizeChanges(rootElement);
        
        assertJavaFileNotExists(INTERFACE_NAME);
    }
    
    @Test
    def testAddSuperInterface() {
        createInterfaceWithTwoSuperInterfaces(INTERFACE_NAME, SUPERINTERFACENAME_1, SUPERINTERFACENAME_2);
        saveAndSynchronizeChanges(rootElement)
        val jI = getJInterfaceFromName(INTERFACE_NAME);
        assertEquals(SUPERINTERFACENAME_1, getClassifierfromTypeRef(jI.extends.get(0)).name)
        assertEquals(SUPERINTERFACENAME_2, getClassifierfromTypeRef(jI.extends.get(1)).name)
    }
    
    @Ignore @Test
    def testRemoveSuperInterface() {
        val uI = createInterfaceWithTwoSuperInterfaces(INTERFACE_NAME, SUPERINTERFACENAME_1, SUPERINTERFACENAME_2);
        saveAndSynchronizeChanges(rootElement)
        uI.generalizations.remove(0);
        saveAndSynchronizeChanges(rootElement);
        val jI = getJInterfaceFromName(INTERFACE_NAME);
        assertTrue(jI.extends.size.toString, jI.extends.size == 1); //TODO Ist 0 statt 1. Im Model ist es aber richtig.
        assertEquals(SUPERINTERFACENAME_2, getClassifierfromTypeRef(jI.extends.get(0)).name)
        assertJavaFileExists(SUPERINTERFACENAME_1);
    }

    
    /**
     * @return Das Interface namens iName, dass die anderen beiden SuperInterfaces superName1 & superName2 beerbt.
     */
    private def Interface createInterfaceWithTwoSuperInterfaces(String iName, String superName1, String superName2) {
        val super1 = createSimpleUmlInterface(rootElement, superName1);
        val super2  = createSimpleUmlInterface(rootElement, superName2);
        val EList<Interface> supers = new BasicEList<Interface>;
        supers += super1;
        supers += super2;
        return createUmlInterfaceAndAddToModel(rootElement, iName, supers);
    }
    
}
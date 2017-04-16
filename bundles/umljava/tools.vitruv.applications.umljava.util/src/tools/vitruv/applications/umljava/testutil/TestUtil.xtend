package tools.vitruv.applications.umljava.testutil

import org.eclipse.uml2.uml.Feature
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Property
import org.emftext.language.java.members.Field
import org.emftext.language.java.members.Method
import org.emftext.language.java.modifiers.AnnotableAndModifiable
import org.emftext.language.java.modifiers.Final
import org.emftext.language.java.modifiers.Static

import static org.junit.Assert.*
import static tools.vitruv.applications.umljava.util.JavaUtil.*
import static tools.vitruv.applications.umljava.testutil.JavaTestUtil.*
import org.emftext.language.java.modifiers.Abstract
import org.eclipse.uml2.uml.VisibilityKind
import org.emftext.language.java.modifiers.Public
import org.emftext.language.java.modifiers.Private
import org.emftext.language.java.modifiers.Protected
import org.emftext.language.java.types.Void
import org.emftext.language.java.types.TypeReference
import org.emftext.language.java.types.NamespaceClassifierReference
import java.util.List
import org.eclipse.uml2.uml.ParameterDirectionKind
import org.eclipse.emf.common.util.EList
import org.eclipse.uml2.uml.EnumerationLiteral
import org.emftext.language.java.members.EnumConstant
import org.apache.log4j.Logger

class TestUtil {
	
	private static val logger = Logger.getLogger(TestUtil)
	
	private new() {
		
	}
	
	/**
	 * Does not compare the methods and attributes of the classes
	 */
	def static void assertClassEquals(org.eclipse.uml2.uml.Class uClass, org.emftext.language.java.classifiers.Class jClass) {
		assertEquals(uClass.name, jClass.name)
		assertAbstractClassEquals(uClass, jClass)
		assertFinalClassEquals(uClass, jClass)
		assertVisibilityEquals(uClass, jClass)
		assertPackageEquals(uClass, jClass)
	}
	
	def static void assertInterfaceEquals(org.eclipse.uml2.uml.Interface uInterface, org.emftext.language.java.classifiers.Interface jInterface) {
		assertEquals(uInterface.name, jInterface.name)
		assertVisibilityEquals(uInterface, jInterface)
		assertPackageEquals(uInterface, jInterface)
	}
	
	def static void assertAttributeEquals(Property uAttribute, Field jAttribute) {
		assertEquals(uAttribute.name, jAttribute.name)
		assertVisibilityEquals(uAttribute, jAttribute)
		assertFinalAttributeEquals(uAttribute, jAttribute)
		assertStaticEquals(uAttribute, jAttribute)
		assertTypeEquals(uAttribute.type, jAttribute.typeReference)
	}
	
	def static assertPackageEquals(org.eclipse.uml2.uml.Classifier uClassifier, org.emftext.language.java.classifiers.Classifier jClassifier) {
		//TODO
	}
	
	def static void assertEnumEquals(org.eclipse.uml2.uml.Enumeration uEnum, org.emftext.language.java.classifiers.Enumeration jEnum) {
		assertEquals(uEnum.name, jEnum.name)
		assertVisibilityEquals(uEnum, jEnum)
		assertEnumConstantListEquals(uEnum.ownedLiterals, jEnum.constants)
	}
	
	def static void assertEnumConstantListEquals(List<EnumerationLiteral> uEnumLiteralList, List<EnumConstant> jEnumConstantList) {
		assertEquals(uEnumLiteralList.size, jEnumConstantList.size)
		for (uLiteral : uEnumLiteralList) {
			val jConstants = jEnumConstantList.filter[name == uLiteral.name]
			if (jConstants.nullOrEmpty) {
				fail("There is no corresponding java enum constant with the name '" + uLiteral.name + "'")
			} else if (jConstants.size > 1) {
				logger.warn("There are more than one parameter with the name '" + uLiteral.name + "'")
			} else {
				assertEnumConstantEquals(uLiteral, jConstants.head)
			}
		}
	}
	
	def static void assertEnumConstantEquals(EnumerationLiteral uLiteral, EnumConstant jConstant) {
		assertEquals(uLiteral.name, jConstant.name)
	}
	
	def static void assertMethodEquals(Operation uMethod, Method jMethod) {
		assertEquals(uMethod.name, jMethod.name)
		assertStaticEquals(uMethod, jMethod)
		assertAbstractMethodEquals(uMethod, jMethod)
		assertVisibilityEquals(uMethod, jMethod)
		assertTypeEquals(uMethod.type, jMethod.typeReference)
		assertParameterListEquals(uMethod.ownedParameters, jMethod.parameters)
	}
	
	def static void assertStaticEquals(Feature uElement, AnnotableAndModifiable jElement) {
		if (uElement.static) {
			assertTrue(jElement.hasModifier(Static))
		} else {
			assertFalse(jElement.hasModifier(Static))
		}
	}
	
	def static void assertFinalClassEquals(org.eclipse.uml2.uml.Class uClass, org.emftext.language.java.classifiers.Class jClass) {
		if (uClass.finalSpecialization) {
			assertTrue(jClass.hasModifier(Final))
		} else {
			assertFalse(jClass.hasModifier(Final))
		}
	}
	
	def static void assertFinalAttributeEquals(Property uAttribute, Field jAttribute) {
		if (uAttribute.readOnly) {
			assertTrue(jAttribute.hasModifier(Final))
		} else {
			assertFalse(jAttribute.hasModifier(Final))
		}
	}
	
	def static void assertAbstractClassEquals(org.eclipse.uml2.uml.Class uClass, org.emftext.language.java.classifiers.Class jClass) {
		if (uClass.abstract) {
			assertTrue(jClass.hasModifier(Abstract))
		} else {
			assertFalse(jClass.hasModifier(Abstract))
		}
	}
	
	def static void assertAbstractMethodEquals(Operation uMethod, Method jMethod) {
		if (uMethod.abstract) {
			assertTrue(jMethod.hasModifier(Abstract))
		} else {
			assertFalse(jMethod.hasModifier(Abstract))
		}
	}
	
	def static void assertVisibilityEquals(org.eclipse.uml2.uml.NamedElement uElement, AnnotableAndModifiable jElement) {
		val jVisibility = getJavaVisibilityConstantFromUmlVisibilityKind(uElement.visibility)
		assertJavaModifiableHasVisibility(jElement, jVisibility)
	}
	
	def static void assertTypeEquals(org.eclipse.uml2.uml.Type uType, TypeReference jTypeReference) {
		if (uType === null) {
			assertTrue(jTypeReference instanceof Void)
		} else if (jTypeReference instanceof org.emftext.language.java.types.PrimitiveType) {
			assertPrimitiveTypeEquals(uType, jTypeReference)
		} else if (jTypeReference instanceof NamespaceClassifierReference) {
			assertNamespaceClassifierReferenceTypeEquals(uType, jTypeReference)
		} else {
			throw new IllegalArgumentException("The java TypeReference is neither a PrimitiveType nor a NamespaceClassifierReference")
		}
	}
	
	def static void assertPrimitiveTypeEquals(org.eclipse.uml2.uml.Type uPrimitiveType, org.emftext.language.java.types.PrimitiveType jPrimitiveType) {
		assertEquals(uPrimitiveType.name, jPrimitiveType.eClass.name.toLowerCase)
	}
	
	def static void assertNamespaceClassifierReferenceTypeEquals(org.eclipse.uml2.uml.Type uType, NamespaceClassifierReference jNamespaceClassifierReference) {
		 assertEquals(uType.name, getClassifierFromNameSpaceReference(jNamespaceClassifierReference).name)
	}
	
	def static void assertParameterListEquals(List<org.eclipse.uml2.uml.Parameter> uParamList, List<org.emftext.language.java.parameters.Parameter> jParamList) {
		val uParamListWithoutReturn = uParamList.filter[direction != ParameterDirectionKind.RETURN_LITERAL]
		if (uParamListWithoutReturn == null) {
			assertNull(jParamList)
		} else {
			assertEquals(uParamListWithoutReturn.size, jParamList.size)
			for (uParam : uParamListWithoutReturn) {
				val jParams = jParamList.filter[name == uParam.name]
				if (jParams.nullOrEmpty) {
					fail("There is no corresponding java parameter with the name '" + uParam.name + "'")
				} else if (jParams.size > 1) {
					println("There are more than one parameter with the name '" + uParam.name + "'")
				} else {
					assertParameterEquals(uParam, jParams.head)
				}
			}
		}
	}
	
	def static void assertParameterEquals(org.eclipse.uml2.uml.Parameter uParameter, org.emftext.language.java.parameters.Parameter jParameter) {
		assertEquals(uParameter.name , jParameter.name)
		assertTypeEquals(uParameter.type, jParameter.typeReference)
	}
	
	
	
}
package tools.vitruv.applications.pcmjava.tests.pojotransformations.gplimplementation.java2pcm

import tools.vitruv.applications.pcmjava.tests.pojotransformations.java2pcm.ClassMethodMappingTransformationTest

class ClassMethodMappingGplTransformationTest extends ClassMethodMappingTransformationTest {
	override protected createChange2CommandTransformingProviding() {
		Change2CommandTransformingProvidingFactory.createJava2PcmGplImplementationTransformingProviding();
	}
}
import Testing
@testable import NMRCalculatorCommon

@Test func testNMRNucleusTableLoader() async throws {
    let loader = await NMRNucleusTableLoader.shared
    
    #expect(loader.loaded)
    #expect(loader.nmrNucleusTable().count == 120, "Expected 120 entries in the table")
}

@Test func testNMRNucleusTable() async throws {
    let table = await NMRNucleusTable()
    
    #expect(table.nuclei[0] == NMRNucleus())
}

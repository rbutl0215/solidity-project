import { artifacts, ethers, waffle } from "hardhat";
import type { Artifact } from "hardhat/types";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { Signers } from "../types";
import { Project } from "../../src/types/Project";
import { expect } from "chai";

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];
  });

  describe("Projects", function () {
    beforeEach(async function () {
      const projectArtifact: Artifact = await artifacts.readArtifact("Project");
      this.project = <Project>await waffle.deployContract(this.signers.admin, projectArtifact, [[]]);
    });

    it("should return the owner's address", async function () {
      expect(await this.project.connect(this.signers.admin).getOwnerAddress()).to.equal(this.signers.admin.address);
    });

    it("should let you add employees", async function () {
      const signers: SignerWithAddress[] = await ethers.getSigners();

      const employee1 = signers[1];

      const employeeAddress = employee1.address;

      await this.project.connect(this.signers.admin).addEmployee(employeeAddress);

      expect(await this.project.connect(this.signers.admin).getEmployeeAddresses()).to.contain(employeeAddress);
    });
  });
});

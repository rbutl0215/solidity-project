import { artifacts, ethers, waffle } from "hardhat";
import type { Artifact } from "hardhat/types";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { Signers } from "../types";
import { Project } from "../../src/types/Project";
import { expect } from "chai";
import { BigNumber } from "ethers";

describe("Unit tests", function () {
  let adminAction: any;
  let employee1: SignerWithAddress;
  let employee2: SignerWithAddress;

  const oneEth: BigNumber = ethers.utils.parseEther("1.0");

  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];
    employee1 = signers[1];
    employee2 = signers[2];
  });

  describe("Projects", function () {
    beforeEach(async function () {
      const projectArtifact: Artifact = await artifacts.readArtifact("Project");
      this.project = <Project>await waffle.deployContract(this.signers.admin, projectArtifact, [[]]);

      adminAction = this.project.connect(this.signers.admin);
    });

    it("should return the owner's address", async function () {
      expect(await adminAction.getOwnerAddress()).to.equal(this.signers.admin.address);
    });

    it("should let you add employees", async function () {
      await adminAction.addEmployee(employee1.address);
      expect(await adminAction.getEmployeeAddresses()).to.contain(employee1.address);
    });

    it("should allow you pay an employee if the project has a sufficient balance", async function () {
      await this.signers.admin.sendTransaction({
        to: this.project.address,
        value: oneEth, // Sends exactly 1.0 ether
      });

      expect(await adminAction.getBalance()).to.equal(oneEth);

      await adminAction.payEmployee(employee1.address, oneEth);

      expect(await adminAction.getBalance()).to.equal(0);
    });

    it("should allow you to deploy a PaymentSplitter contract", async function () {
      await this.signers.admin.sendTransaction({
        to: this.project.address,
        value: oneEth, // Sends exactly 1.0 ether
      });

      await adminAction.createPayment([employee1.address, employee2.address], [80, 20]);

      const payments = await adminAction.getPayments();

      expect(payments.length).to.equal(1);
    });
  });
});

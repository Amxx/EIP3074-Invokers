const { ethers   } = require('ethers');
const { solidity } = require('ethereum-waffle');
const chai         = require('chai');
const { expect   } = chai;

chai.use(solidity);

const invoker    = require('../compiled/Invoker.json');
const receiver   = require('../compiled/ContractReceiverMock.json');


function hashAuth(invokerAddress, commit) {
  return ethers.utils.keccak256(ethers.utils.concat([
    ethers.utils.toUtf8Bytes('\x03'),
    ethers.utils.zeroPad(ethers.utils.getAddress(invokerAddress), 32),
    ethers.utils.zeroPad(commit, 32),
  ]));
}

function signAuth(signingKey, invokerAddress, commit) {
  return signingKey.signDigest(hashAuth(invokerAddress, commit));
}


async function deploy(abi, bytecode, signer, ...params) {
  const Contract = new ethers.ContractFactory(abi, bytecode, signer);
  return await Contract.deploy(...params).then(f => f.deployed());
}


describe('Invoker', function () {
  before(async function() {
    this.provider = ethers.getDefaultProvider('http://localhost:8545');
    this.signer   = new ethers.Wallet(process.env.MNEMONIC1).connect(this.provider);
    this.other    = ethers.Wallet.createRandom().connect(this.provider);
    this.target   = await deploy(receiver.abi, receiver.bytecode, this.signer, { gasLimit: 125089 });
  });

  beforeEach(async function () {
    this.instance = await deploy(invoker.abi, invoker.bytecode, this.signer, { gasLimit: 760653 });
  });

  describe('batch', function () {
    it('success', async function () {
      const authsig  = ethers.utils.joinSignature(signAuth(this.signer._signingKey(), this.instance.address, ethers.constants.HashZero));

      await expect(this.instance.connect(this.signer).batch(
        [ this.target.address ],
        [ 0 ],
        [ '0xd909b403' ],
        authsig,
        { gasLimit: 1000000 }
      )).to.emit(this.target, 'Received').withArgs(
        this.signer.address,
        0,
        '0xd909b403'
      );
    });

    it('batched call revert', async function () {
      const authsig  = ethers.utils.joinSignature(signAuth(this.signer._signingKey(), this.instance.address, ethers.constants.HashZero));

      // await expect(this.instance.connect(this.signer).batch(
      //   [ this.target.address ],
      //   [ 0 ],
      //   [ '0xa9cc4718' ],
      //   authsig,
      //   { gasLimit: 1000000 }
      // )).to.be.revertedWith("toto");

      const tx = await this.instance.connect(this.signer).batch(
        [ this.target.address ],
        [ 0 ],
        [ '0xa9cc4718' ],
        authsig,
        { gasLimit: 1000000 }
      );

      await expect(tx.wait()).to.be.revertedWith("toto");
    });

    it('invalid signature', async function () {
      const authsig = ethers.utils.joinSignature(signAuth(this.other._signingKey(), this.instance.address, ethers.constants.HashZero));

      // await expect(this.instance.connect(this.signer).batch(
      //   [ this.target.address ],
      //   [ 0 ],
      //   [ '0xa9cc4718' ],
      //   authsig,
      //   { gasLimit: 1000000 }
      // )).to.be.revertedWith("toto");

      const tx = await this.instance.connect(this.signer).batch(
        [ this.target.address ],
        [ 0 ],
        [ '0xa9cc4718' ],
        authsig,
        { gasLimit: 1000000 }
      );

      await expect(tx.wait()).to.be.revertedWith("toto");
    });
  });

});

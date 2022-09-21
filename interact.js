require("@nomiclabs/hardhat-ethers");
var fs = require('fs');
const util = require('util');
var ethers = require('ethers');
const { get } = require("http");
const { profile } = require("console");
const fsPromises = fs.promises;

// The path to the contract ABI
const ABI_FILE_PATH = 'artifacts/contracts/nft.sol/nft.json';
// The address from the deployed smart contract
const DEPLOYED_CONTRACT_ADDRESS = '0x97c60D41B0d36eC1eF5215169686A6a3e1359Ef2';

// load ABI from build artifacts
async function getAbi(){
  const data = await fsPromises.readFile(ABI_FILE_PATH, 'utf8');
  const abi = JSON.parse(data)['abi'];
  //console.log(abi);
  return abi;
}

async function main() {
    let provider = ethers.getDefaultProvider("https://rinkeby.infura.io/v3/a01779fde7e24c0f9d628e47a243ee6d");
    const abi = await getAbi()

    
    // READ-only operations require only a provider.
    // Providers allow only for read operations.
    // function to read only : 

    // function to get nft_URL by id 
    async function get_url(id){
        let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
        const url =await contract._TokenURI(id);
        return url
    }

   // function to get the balance of nfts by address of wallet 
   async function get_balance(_address){
    let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
    const count = await contract.balanceOf(_address);
    return count.toString()
    }

   // function to get all pending nfts with(1:id ,2:authors,3:owner,4:status)
   async function findallpending(){
    let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
    const all = await contract.findAllPendingnft();
    return all.toString()
    }
 
  // funtion to get all approved address for nft by nft id 
  async function get_approved(id){
    let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
    const approved_address= await contract.getApproved(id);
    return approved_address.toString()
    }
  
 //funtion to get name of collection 
 async function get_collection_name(){
      let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
      const name = await contract.get_name();
      return name
       }
   
// function to get symbol of collection 
 async function getsymbol(){
    let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
    const symbol= await contract.get_symbol();
    return symbol
 }
 // funtion to get index 
 async function index(){
    let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
    const index = await contract.index();
    return index.toString()
 }
// funtion to check in approved for address 
 async function isapproved_foraddress(owner , operator ){
    let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
    const is = await contract.isApprovedForAll(owner,operator);
    return is 
 }

// function to check ownership for nft by id and address 
 async function isowner(id,address){
     let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
     const is = await contract.isOwnerOf(id,address);
     return is.toString()

 }
// funtion to get the owner of nft by id 
 async function get_onwer(id){
    let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
    const onwer= await contract.ownerOf(id);
    return onwer
 }


    //function to find nft by id 
    async function findnft(id){
        let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS, abi, provider);
        const information = await contract.findnft([id]);
        return information.toString()
    }
    

   // funtion to get price by id 
    async function get_price(id){
        let contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
        const price = await contract.get_price(id);
        return price.toString()
    }


    // WRITE operations require a signer
     /*
     WAIT for METAMASK LINK IN FRONTEND ,SO TO TRY I USE MY METAMASK'S PRIVATE KEY :
     */
    const  PRIVATE_KEY  = "343b2acff62052f01942fe76d098da05e56c7a296f129759e02492ec72609f9e"
    let signer = new ethers.Wallet(PRIVATE_KEY, provider);
  
    // funtion to mint image 
    async function mint(_title,_description,_date,_authorName,_price,_image,url){
    const new_contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS, abi, signer);
    const mint= await new_contract.createToken(_title,_description,_date,_authorName,_price,_image,url);

 }
  adnan = await mint("hi","yes","i","can",1,"now","some link");
  

 // function to make address aprroved 
    async function give_approved(to,nftid){
        const contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,signer);
        const approv= await contract.approve(to,nftid);
    }

    // function to buy nft by id 
    async function buy(id){
        //const options = {value: ethers.utils.parseEther("0.000000000001")}
        let price = 0;
        price = await get_price(id);
        const contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,signer);
        const options = {value: price,gasLimit : 300000}

        const buy = await contract.buynft(id,options);
    }
    
    //x=await buy(1);
 // function to resell nft with new price 
    async function resell(id,price ){
        //const options = {value: ethers.utils.parseEther("0.000000000000001")}
        //const new_contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,provider);
        const contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,signer);
        //const estimation = await new_contract.estimateGas.transfer(DEPLOYED_CONTRACT_ADDRESS, price);
        //const options = {value: estimation};
        const resell = await contract.resellnft(id,price,{ gasLimit: 100000});

  }

  // function to withdraw asset from samrtcontract for only the owner  
  async function withdraw(){
    const contract = new ethers.Contract(DEPLOYED_CONTRACT_ADDRESS,abi,signer);
    const withd = await contract.withdraw();
  }



    //x=await buy(2);
   
 //x = await mint("title","hi to all","12jun","jamil",1,"shi","ipfs://QmWCbWACN5S9wWJtb2RPGvYMjvSXrAsq4dCXWJqZ29NDDg/");


  //x=await buy(1);
  x=await findnft(1);
  console.log(x);
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
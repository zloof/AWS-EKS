const AWS = require('aws-sdk');
const ObjectsToCsv = require('objects-to-csv');

AWS.config.update({region:'us-east-1'});
let ec2 = new AWS.EC2();


function main(){
  getAllResources().then(async resourcesList =>
    {
      var myArgs = process.argv.slice(2);
      const fileName = (myArgs[0])?myArgs[0]:"aws-bizzabo-resources"
      const fileLocation = `./${fileName}.csv`;
      console.log('fileLocation: ', fileLocation);
      const csv = new ObjectsToCsv(resourcesList);
      await csv.toDisk(fileLocation);
    });
}
main();


async function getAllResources(){
  let resourcesList = [];
  try{
    let regionsObj = await ec2.describeRegions({}).promise()
    let regionsList = regionsObj.Regions.map(region => region.RegionName);
    let promises = regionsList.map(regionName => getAllResourcesByRegion(regionName))
    let results = await Promise.all(promises);
    resourcesList = results.reduce((accumulator, currentValue)  => accumulator.concat(currentValue));
    resourcesList = resourcesList.map(result => {
                    let service = /arn:aws:([^:]*).*/g.test(result.ResourceARN)?RegExp.$1:""
                    let type = /arn:aws:[^:]*:[^:]*:[0-9]*:([^/]*)/g.test(result.ResourceARN)?RegExp.$1:""
                    return {"arn":result.ResourceARN,
                            "service":service,
                            "type":type}
                });
  }
  catch(ex){
    console.log("error:",ex.message)
    results = JSON.stringify(ex);
  }
  return resourcesList;
}

async function getAllResourcesByRegion(region){
  let totalRegionResources = [];
  const aws = require('aws-sdk');
  aws.config.update({region:region});
  var resourceGroupsTaggingAPI = new aws.ResourceGroupsTaggingAPI();
  var params = {};
  let resourcesPage =  await resourceGroupsTaggingAPI.getResources(params).promise();
  totalRegionResources = totalRegionResources.concat(resourcesPage.ResourceTagMappingList)
  while (resourcesPage.PaginationToken){
    params.PaginationToken = resourcesPage.PaginationToken
    resourcesPage =  await resourceGroupsTaggingAPI.getResources(params).promise();
    totalRegionResources = totalRegionResources.concat(resourcesPage.ResourceTagMappingList)
  }
  return totalRegionResources;
}

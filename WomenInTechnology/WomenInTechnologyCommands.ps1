.\CreateCFNStack.ps1 -Region ap-southeast-2 -Class WomenInTechnology -Environment SharedInf

.\CreateCFNStack.ps1 -Region ap-southeast-2 -Class WomenInTechnology -Environment AutoSubnet

.\CreateCFNStack.ps1 -Region ap-southeast-2 -Class WomenInTechnology -ClassRoster E:\Git\CFClassTemplates\WomenInTechnologyWorkstations.txt -ServerOS AMALINUX -Environment Bastion

.\DeleteCFNStack.ps1 -region ap-southeast-2 -Environment Bastion

.\DeleteCFNStack.ps1 -region ap-southeast-2 -Environment AutoSubnet

.\DeleteCFNStack.ps1 -region ap-southeast-2 -Environment SharedInf

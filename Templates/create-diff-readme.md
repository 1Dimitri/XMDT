* In order to create a diff file

1. Launch cmd, as powershell may create file encoding issues
1. Create a new blank MDT Share
1. diff Original-File-In-The-MDT-Share.wsf  File-Modified.wsf > ile-In-The-MDT-Share.wsf.diff

In powershell: 
New-XMDTShare C:\MDTReference
In cmd:
diff C:\MDTReference\Scripts\ZTINicConfig.wsf C:\WorkspaceMDT\Scripts\ZTINicConfigNewVersion.wsf > C:\patches\ZTINicConfig.wsf.diff
Copy the .diff files in Templates\Scripts 

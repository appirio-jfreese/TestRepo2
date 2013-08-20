<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Video_share_link_file</fullName>
        <field>share_link__c</field>
        <formula>&quot;http://diageodirect.force.com/apex/Preview?videoId=&quot;+ Video_Id__c</formula>
        <name>Video share link file</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>new_file_uploaded</fullName>
        <apiVersion>23.0</apiVersion>
        <endpointUrl>http://pa.diageodirect.com/prod/FIn.php</endpointUrl>
        <fields>Content_ID__c</fields>
        <fields>Content_Version_Id__c</fields>
        <fields>Description__c</fields>
        <fields>Id</fields>
        <fields>Title__c</fields>
        <fields>filetype__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>previewuser@previewuser.prod</integrationUser>
        <name>new file uploaded</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>new file uploaded</fullName>
        <actions>
            <name>new_file_uploaded</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(ISCHANGED( Content_Version_Id__c )   || ISNEW()) &amp;&amp;  filetype__c !=&apos;Video&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>share link video</fullName>
        <actions>
            <name>Video_share_link_file</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Is_Video__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

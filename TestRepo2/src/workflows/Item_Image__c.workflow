<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Product_Image_URL</fullName>
        <description>Clears the &quot;Product Image URL&quot; field on the Item (parent) everytime an image type excludes &quot;Image&quot;</description>
        <field>Product_Image_URL__c</field>
        <name>Clear Product Image URL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <targetObject>Item__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Product_Image_URL</fullName>
        <description>Sets the &quot;Product Image URL&quot; field on the Item (parent) everytime an image type includes &quot;Image&quot;</description>
        <field>Product_Image_URL__c</field>
        <formula>Magento_Image_URL__c</formula>
        <name>Set Product Image URL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Item__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Clear Product Image</fullName>
        <actions>
            <name>Clear_Product_Image_URL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Item_Image__c.Image_Types__c</field>
            <operation>excludes</operation>
            <value>image</value>
        </criteriaItems>
        <description>Clears the product image on the related Item (parent) everytime an image type excludes &quot;Image&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Product Image</fullName>
        <actions>
            <name>Set_Product_Image_URL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Item_Image__c.Image_Types__c</field>
            <operation>includes</operation>
            <value>image</value>
        </criteriaItems>
        <description>Sets the product image on the related Item (parent) everytime an image type includes &quot;Image&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

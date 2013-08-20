<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Create Records</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Objective__c.Name</field>
            <operation>notContain</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Goal_Sales_Channel_Display_Visibilit</fullName>
        <field>Sales_Channel__c</field>
        <literalValue>Display/Visibility</literalValue>
        <name>Goal - Sales Channel - Display/Visibilit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Goal_Sales_Channel_Distribution</fullName>
        <field>Sales_Channel__c</field>
        <literalValue>Distribution</literalValue>
        <name>Goal - Sales Channel - Distribution</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Goal_Sales_Channel_INP</fullName>
        <field>Sales_Channel__c</field>
        <literalValue>Integrated National Program</literalValue>
        <name>Goal - Sales Channel - INP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Goal_Sales_Channel_Innovation</fullName>
        <field>Sales_Channel__c</field>
        <literalValue>Innovation</literalValue>
        <name>Goal - Sales Channel - Innovation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Goal_Sales_Channel_Sustainovation</fullName>
        <field>Sales_Channel__c</field>
        <literalValue>Sustainovation</literalValue>
        <name>Goal - Sales Channel - Sustainovation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Sum_of_Loc_Goals_Reporting</fullName>
        <field>Local_Goals__c</field>
        <formula>Local__c</formula>
        <name>Update the Sum of Loc. Goals - Reporting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Sum_of_Nat_Goals_Reporting</fullName>
        <field>National_Goals__c</field>
        <formula>National__c</formula>
        <name>Update the Sum of Nat. Goals - Reporting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Flip Goal Sales Channel - Display%2FVisibility</fullName>
        <actions>
            <name>Goal_Sales_Channel_Display_Visibilit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule updates the Goal&apos;s Sales Channel with the associated Program&apos;s Display/Visibility Sales Channel</description>
        <formula>ISPICKVAL( Program__r.Sales_Channel__c, &quot;Display/Visibility&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Flip Goal Sales Channel - Distribution</fullName>
        <actions>
            <name>Goal_Sales_Channel_Distribution</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule updates the Goal&apos;s Sales Channel with the associated Program&apos;s Distribution Sales Channel</description>
        <formula>ISPICKVAL (Program__r.Sales_Channel__c, &quot;Distribution&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Flip Goal Sales Channel - INP</fullName>
        <actions>
            <name>Goal_Sales_Channel_INP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule updates the Goal&apos;s Sales Channel with the associated Program&apos;s INP Sales Channel</description>
        <formula>ISPICKVAL(Program__r.Sales_Channel__c, &quot;Integrated National Program&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Flip Goal Sales Channel - Innovation</fullName>
        <actions>
            <name>Goal_Sales_Channel_Innovation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule updates the Goal&apos;s Sales Channel with the associated Program&apos;s Innovation Sales Channel</description>
        <formula>ISPICKVAL (Program__r.Sales_Channel__c, &quot;Innovation&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Flip Goal Sales Channel - Sustainovation</fullName>
        <actions>
            <name>Goal_Sales_Channel_Sustainovation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule updates the Goal&apos;s Sales Channel with the associated Program&apos;s Sustainovation Sales Channel</description>
        <formula>ISPICKVAL (Program__r.Sales_Channel__c, &quot;Sustainovation&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set %23 of Local Goals</fullName>
        <actions>
            <name>Update_the_Sum_of_Loc_Goals_Reporting</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Goal__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set %23 of National Goals</fullName>
        <actions>
            <name>Update_the_Sum_of_Nat_Goals_Reporting</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Goal__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

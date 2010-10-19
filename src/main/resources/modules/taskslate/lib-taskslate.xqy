

declare function create-task() as element() {
<item>
 <id>1</id>
 <project>jpmc</project>
 <task>Disk space monitoring widget</task>
 <stakeholder>pbarker</stakeholder>
 <assignee>ableasdale</assignee>
 <status>in-progress</status>
 <estimate>{xs:duration('PT15H')}</estimate>
 <due-dateTime>{fn:current-dateTime()}</due-dateTime>
 <comments>reliant upon ODS-959 being completed</comments>

 <workflows>
  <workflow>
    <dateTime>{fn:current-dateTime()}</dateTime>
    <event>created</event>
  </workflow>
  <workflow>
    <dateTime>{fn:current-dateTime()}</dateTime>
    <event>complete</event>
  </workflow>
 </workflows>
</item>
};
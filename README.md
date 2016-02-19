# Trigger Action Handler
A CRM component in which agents (users) can set up events that trigger actions based on a set of conditions.

### The Problem
CRM users would like the ability to set up automated events that execute under a set of conditions. For example, "if a deal get's cancelled, cancel all related events". Unlike the typical callback approach, which must be progamatically maintained, they need a solution that let's non-technical users generate the system's behavior.

### The Solution
A system of related data models alongside a database transaction interceptor. The data models provide a structure for storing trigger/condition/action events. The database transaction interceptor captures each CRUD transaction and executes the logic around any related triggers.

##### The Data Models

###### Primary

1. `trigger` - stores the class type of the objects to observe as well as the type of action to observe. For example, "if deal get's cancelled" would create a trigger that watches the `Deal` class for an `update` action.
2. `condtion` - represents a condition by relating a set of `field` and `value` together with an `operator`. For example, "if deal get's cancelled" would have a condition with a field `"deal_stage"`, value `"cancelled"`, and operator `"=="`.
3. `action` - action ties a trigger to a CRUD action. It is related to a `field_value_pair` that is used to find the object that is to be updated in the case where the action is an update or destroy. It is also related to a set of `field_value_pairs` that are used to update or create an object. For example, "cancel all related events" will have an `action` that finds the `events` that got cancelled via a `lookup_field_value_pair` and changes the `events` with a `change_field_value_pair` having field `canceled` and value `true`.

###### Supporting

1. `condition_trigger_join` - join table as well as storage for `operator` metadata. For example, multiple conditions may be tied to one trigger. The operator can be set to `&&` or `||` which will be accounted for when concatinating the conditions. Note, the condtitions are only executed horizontally at the same level. Meaing `condition1 && condition2 || condition3` is possible but not `(condition1 && condition2) || condition3`
2. `crud_action` - houses the name for the CRUD actions being considered. Currently used in trigger and action and excludes read as it is not required.
3. `field_value_pairs` - used in relation to `conditions` and `actions` to store pairs used in an object's parameters hash.

##### Database Transaction Interceptor

The interceptor is found in `global_observer.rb`. It contains an `after_commit` callback that is run on every ActiveRecord transaction. The callback executes the `TriggerHandler`'s primary method, `perform`.
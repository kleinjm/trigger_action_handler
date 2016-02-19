# Trigger Action Handler
A CRM component in which agents (users) can set up events that trigger actions based on a set of conditions.

### The Problem
CRM users would like the ability to set up automated events that execute under a set of conditions. For example, "if a deal get's cancelled, cancel all related events". Unlike the typical callback approach, which must be programmatically maintained, they need a solution that let's non-technical users generate the system's behavior.

### The Solution
A system of related data models alongside a database transaction interceptor. The data models provide a structure for storing trigger/condition/action events. The database transaction interceptor captures each CRUD transaction and executes the logic around any related triggers.

#### The Data Models

###### Primary

1. `trigger` - stores the class type of the objects to observe as well as the type of action to observe. For example, "if deal get's cancelled" would create a trigger that watches the `Deal` class for an `update` action.
2. `condition` - represents a condition by relating a set of `field` and `value` together with an `operator`. For example, "if deal get's cancelled" would have a condition with a field `"deal_stage"`, value `"cancelled"`, and operator `"=="`.
3. `action` - action ties a `trigger` to a CRUD action. It is related to a `field_value_pair` that is used to find the object that is to be acted upon in the case where the CRUD action is an update or destroy. It is also related to a set of `field_value_pairs` that are used to update or create an object. For example, "cancel all related events" will have an `action` that finds the `events` that got cancelled via a `lookup_field_value_pair` and changes the `events` with a `change_field_value_pair` having `field` `"canceled"` and `value` `true`.

###### Supporting

1. `condition_trigger_join` - join table for `condition` and `trigger` as well as storage for `operator` metadata. Multiple `conditions` may be tied to one `trigger`. The operator can be set to `"&&"` or `"||"` which will be accounted for when concatenating the conditions. Note, the conditions are only executed horizontally (at the same level). Meaning `condition1 && condition2 || condition3` is possible but not `(condition1 && condition2) || condition3`
2. `crud_action` - houses the name for the CRUD actions being considered. Currently used in `trigger` and `action` and excludes CRUD's Read as it is not required.
3. `field_value_pairs` - used in relation to `conditions` and `actions` to store pairs used in an object's parameters hash.

#### Database Transaction Interceptor

The interceptor is found in `global_observer.rb`. It contains an `after_commit` callback that is run on every ActiveRecord transaction. The callback instantiates a `TriggerHandler` and executes it's main method, `perform`.

Instance method `perform` executes in the following manner.

1. Find any triggers related to the given object type and transaction type.
2. For each trigger, see if the conditions are met.
3. If all conditions are met (AND or OR depending on the trigger/condition join), execute the CRUD actions.

Helper functions provide the iteration and execution of these high level steps.

#### Final Product
The functionality is in place and easily extensible. There is currently no user interface though the following section explains how one may be implemented. To see the true power of the application, direct your attention to the tests in `trigger_handler_spec.rb` which provide a variety of trigger/condition/action combinations. Every CUD (CRUD - Read) action is used and some unique cases are displayed such as doing a lookup via a related table or accessing an attribute via a related object. Some complex cases of multiple actions and/or conditions are shown as well.

#### Possible UI
The pattern of behavior of this feature immediately makes me think of dynamically generated nested forms. The type of front-end functionality I have in mind is supported by gems such as [Cocoon](https://github.com/nathanvda/cocoon). 

The user would start with a basic trigger form. They select which object to observe from a list of dynamically generated objects that exist in the application (probably with whitelisting so they don't see all). Then they select what crud action. Using JavaScript, forms for conditions and actions are displayed. The same type of dropdowns could be generated for the fields of the objects that they are interacting with so that they avoid errors in typing in a name of a field. To add additional conditions or actions, "+" sign icons would be nested within each section of the sub-forms to indicate which level of functionality is being extended. For advanced lookup of related objects, a modal could be displayed that allows users to dive deep into creating a custom query. As with the main form functionality, this modal form would throttle the level of access that users have so that they do not disrupt the behavior of sensitive models.

The form and sub-forms would submit to a thin controller that feeds the data to a handler responsible for building the objects, running validations, and saving them as trigger/condition/action combinations.

### Problem Solving Approach

##### Typical Solution
This is a unique problem. Typically each trigger/action would be made into a feature request for some custom functionality and handled when the development team has the time and is at the priority level. A solution such as this takes a lot off the plates of both the client and development team by putting the behavior of the system into the hands of the client.

##### Dynamic Solution
My first thought was that every trigger is fired by a CRUD transaction with the database. I wanted to intercept these transactions in a non-obtrusive way. In other words, I could have put a callback in every model that I wanted to watch to hit a generic handler, but I wanted to make the model observing programmatic as well. I wanted to ensure that new models are automatically watched without the developer needing to put in a callback. After some research, I found that I could build an Observer. This was a core piece of Rails until Rails 4+ at which point it was extracted to the [rails-observers](https://github.com/rails/rails-observers) gem. It was a great start but I needed a bit more research to figure out how to have the observer watch every transaction without having to register each model in it. That led to great piece of code that is easily understandable `observe ActiveRecord::Base`. Note, to test the `after_commit` functionality, I used the [test_after_commit](https://github.com/grosser/test_after_commit) gem.

With my interceptor in place, I began to focus on how to model the data storage for the trigger/action events. The breakthroughs in this process came with analyzing the use cases. Let's take an example, 

> If Deal is updated and new deal stage is a "dead" stage, update tasks and events to mark as "cancelled"

Here we see **Deal**, the object, getting **updated**, the CRUD action. Initially, I thought that the value of the update would be coupled with the trigger, but after several use cases, I realized that **"dead"** and **stage** are the conditions. Finally, the "if-then" syntax of every use case made it obvious that the latter half of the statement is the action(s). For simplicity, I focused on just one: object, **task** and field change, **"cancelled"**. Breaking this part of the statement down, we see that **update** is another CRUD action, just like the one used in the trigger, and **"mark as cancelled"** is a field and value that need to be changed.

To recap, trigger = "If Deal is updated", condition = "deal stage is 'dead' stage", and action = "mark as [tasks and events] cancelled".

The relationships were somewhat obvious after figuring out the models. Each trigger could have multiple conditions and actions. While coding examples, I later discovered that a join between condition and trigger should exist to signify AND or OR relations between conditions. Another discovery was noticing the reuse of object param hashes, lead to a refactor in which field <> value pairs were extracted into their own model. The relationship between the change and lookup value pairs and action were refactored so that there was one lookup pair and many change pairs per action. This could be changed in the future to have a one-to-many relationship between action and change pair if the functionality later called for narrower querying of the objects being acted upon.

With the interceptor and data modeling in place, it came down to functionality. The trigger handler was created to house the processing of a given CRUD transaction. It first does a single and inexpensive query to see if any triggers exist. The method will most likely terminate here in most cases. The reasoning being 1) that the transaction must match the model type and crud action in the transaction 2) the number of triggers for each model type and transaction will most likely be small. If any triggers are found, we need to iterate through them, iterate through their conditions, and iterate through their actions.

All development was done via tests. It is the best way to model the behavior of the application and no interface was needed to solve the problem. I explored the path of the form interface briefly but it was not required and would most likely have been cumbersome to maintain while flushing out the functionality. Tests were done using the following gems:

* [guard](https://github.com/guard/guard) - file watcher to run tests on file save.
* [guard-rspec](https://github.com/guard/guard-rspec) - rspec plugin for guard.
* [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner) - flushes the test database between tests.
* [factory_girl_rails](https://github.com/thoughtbot/factory_girl) - a personal favorite used to mock models. Check the `/spec/factories` directory to see my extensive use of this gem.

##### Additional Notes
If I were building this for an established system, I would research the codebase, conceive a solution, and discuss my design with my co-workers and team leads. This is a rather complex bit of functionality and addition to the database schema and not to be implemented without review. This project was built as a tool to understand and test my solution. Finally, a great deal of unit and functional testing would still be needed for each model as well as end-to-end and integration testing once the interface is designed.


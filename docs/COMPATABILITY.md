# Compatibility

Our goal as maintainers is for the library to be compatible with all supported
versions of CRuby/MRI Ruby listed [here](https://endoflife.date/ruby).

To that end, [our build matrix](../.github/tests.yml) includes all these versions.

Any time BelongsToOneOf doesn't work on a supported version of Ruby, it's a bug, and can be
reported [here](https://github.com/gocardless/belongs-to-one-of/issues).

# Deprecation

Whenever a version of Ruby falls out of support, we will mirror that change in BelongsToOneOf
by updating the build matrix and releasing a new major version.

At that point, we will close any issues that only affect the unsupported version, and may
choose to remove any workarounds from the code that are only necessary for the unsupported
version.

We will then bump the major version of BelongsToOneOf, to indicate the break in compatibility.
Even if the new version of BelongsToOneOf happens to work on the unsupported version of Ruby, we
consider compatibility to be broken at this point.

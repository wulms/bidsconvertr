.. documentation master file, created by sphinx-quickstart
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

The BIDSconvertR
================================

The BIDSconvertR is an R-package, which converts MRI DICOM data into the BIDS-speficication.

.. note::

    The BIDSconvertR is still in development and we are happy to get feedback on usability or new features.


Aim
------------

The goal of BIDSconvertR is to provide a workflow, which is able to:

* open the BIDS conversion to the beginner and advanced R-user
* convert DICOM to NIfTI data using dcm2niix (REF)
* structure this data according to the BIDS specification (REF)
* validate the manually entered sequence-ID’s by color-coding
* enable easy access to the BIDS-Validator (Website/Docker) (REF)
* provide the papayaWidget viewer (REF) for inspecting the images
* enable continuous application during data acquisition in ongoing studies

Features
-----------------

* Renaming of unclean subject-ID’s or session-ID’s.
    * This requires a basic understanding of strings and regular expressions in R
* Validation of manually entered sequence-ID's through color coding.


Everytime files or sequences are added, the ‘sequence mapper’ checks if they are new.
Then opens again until everything is declared according to BIDS.
Already processed files are skipped.



Technical requirements
------------------------

* Microsoft 10 and Ubuntu 22.04 supported and tested.
    * MacOS: Not tested, but should work. Maybe you can try it out and contact me, if there are any issues.



What the user needs to know to apply the BIDSconvertR
----------------------------------------------------------

.. important:: What this is not:

    A full-automated workflow, that does everything for you. You need to bring a minimum of background knowledge on files, folders and DICOMS, as described below.

* What is a folder or file? Where is my data?
* What is a folder, containing DICOMS?
* What is a subject- and sequence-ID?
* What is BIDS?
* What is a valid BIDS sequence name for my filename?

So, if you are able to rename and restructure the folders according to BIDS manually, you are able to run the tool, to scale things up.


.. toctree::
   :maxdepth: 1
   :caption: Introduction:

   md_files/bidsconvertr.md


.. toctree::
   :maxdepth: 1
   :caption: Installation:

   md_files/installation.md
   md_files/installation_bidsconvertr.md


.. toctree::
   :maxdepth: 1
   :caption: Workflow:

   md_files/usage_notes.md
   md_files/usage_notes_user_settings.md
   md_files/workflow.md
   md_files/usage_notes_advanced.md


.. toctree::
   :maxdepth: 1
   :caption: Tutorial:

   md_files/tutorial.md


.. toctree::
   :maxdepth: 1
   :caption: Additional information:

   md_files/user_settings_file
   md_files/dcm2niix.md

# Module.mk for xml module
# Copyright (c) 2004 Rene Brun and Fons Rademakers
#
# Authors: Linev Sergey, Rene Brun 10/05/2004

XMLINCDIR := $(XMLDIR)/include
ifeq ($(PLATFORM),win32)
XMLLIBDIR       := $(XMLDIR)/lib/libxml2_a.lib $(XMLDIR)/lib/iconv_a.lib Ws2_32.lib
XMLLIBEXTRA  :=
else
XMLLIBDIR    := -L$(XMLDIR)/.libs
XMLLIBEXTRA  := -lxml2
endif

MODDIR       := xml
MODDIRS      := $(MODDIR)/src
MODDIRI      := $(MODDIR)/inc

XMLDIR       := $(MODDIR)
XMLDIRS      := $(XMLDIR)/src
XMLDIRI      := $(XMLDIR)/inc

##### libRXML #####
XMLL         := $(MODDIRI)/LinkDef.h
XMLDS        := $(MODDIRS)/G__XML.cxx
XMLDO        := $(XMLDS:.cxx=.o)
XMLDH        := $(XMLDS:.cxx=.h)

XMLH         := $(filter-out $(MODDIRI)/LinkDef%,$(wildcard $(MODDIRI)/*.h))
XMLS         := $(filter-out $(MODDIRS)/G__%,$(wildcard $(MODDIRS)/*.cxx))
XMLO         := $(XMLS:.cxx=.o)

XMLDEP       := $(XMLO:.o=.d) $(XMLDO:.o=.d)

XMLLIB       := $(LPATH)/libRXML.$(SOEXT)

# used in the main Makefile
ALLHDRS     += $(patsubst $(MODDIRI)/%.h,include/%.h,$(XMLH))
ALLLIBS     += $(XMLLIB)

# include all dependency files
INCLUDEFILES += $(XMLDEP)

##### local rules #####
include/%.h:    $(XMLDIRI)/%.h
		cp $< $@

$(XMLLIB):      $(XMLO) $(XMLDO) $(MAINLIBS)
		@$(MAKELIB) $(PLATFORM) $(LD) "$(LDFLAGS)" \
		   "$(SOFLAGS)" libRXML.$(SOEXT) $@ "$(XMLO) $(XMLDO)" \
		   "$(XMLLIBDIR)  $(XMLLIBEXTRA) "

$(XMLDS):       $(XMLH) $(XMLL) $(ROOTCINTTMP)
		@echo "Generating dictionary $@..."
		$(ROOTCINTTMP) -f $@ -c $(XMLH) $(XMLL)

$(XMLDO):       $(XMLDS)
		$(CXX) $(NOOPT) $(CXXFLAGS) -I. -o $@ -c $<

all-xml:        $(XMLLIB)

clean-xml:
		@rm -f $(XMLO) $(XMLDO)

clean::         clean-xml

distclean-xml:  clean-xml
		@rm -f $(XMLDEP) $(XMLDS) $(XMLDH) $(XMLLIB)

distclean::     distclean-xml

##### extra rules ######
$(XMLO): %.o: %.cxx
	$(CXX) $(OPT) $(CXXFLAGS) -I$(XMLINCDIR) -o $@ -c $<

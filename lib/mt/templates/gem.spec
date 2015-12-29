%define ruby_version <%= ruby_version %>
%define ruby_major_version <%= ruby_major_version %>

%define install_prefix /opt/rubies/ruby-%{ruby_version}
%define bindir %{install_prefix}/bin
%define gems_dir %{install_prefix}/lib/ruby/gems/%{ruby_major_version}

%define rbname <%= name %>
%define version <%= version %>
%define release <%= release %>

%define gem_dir %{gems_dir}/gems/%{rbname}-%{version}

Summary: Ruby gem %{rbname}
Name: rbgem-%{rbname}

Version: %{version}
Release: %{release}%{?dist}
Group: Development/RubyAlt
License: Distributable
Source0: %{rbname}-%{version}.gem

Requires: ruby-alt = %{ruby_version}
<% requires.each do |r| -%>
Requires: <%= r %>
<% end -%>

BuildRequires: ruby-alt = %{ruby_version}
<% build_requires.each do |r| -%>
BuildRequires: <%= r %>
<% end -%>

%description
Ruby gem %{rbname}

%prep
%setup -T -c

%build
gem install --no-user-install --no-ri --no-rdoc --local --install-dir ./ --force %{SOURCE0}
find extensions/ -name '*.so' -delete

%install
%{__rm} -rf %{buildroot}
mkdir -p %{buildroot}%{gem_dir}
mkdir -p %{buildroot}%{bindir}
cp -R gems/%{rbname}-%{version}/lib %{buildroot}%{gem_dir}
cp -R cache extensions specifications %{buildroot}%{gems_dir}/

if [ -e gems/%{rbname}-%{version}/bin ]; then
  cp -R gems/%{rbname}-%{version}/bin %{buildroot}%{gem_dir}
  cp gems/%{rbname}-%{version}/bin/* %{buildroot}%{bindir}
fi

%files
%defattr(-,root,root,-)
%attr(755,root,root) %{bindir}
%{gems_dir}/gems
%{gems_dir}/cache
%{gems_dir}/specifications
%{gems_dir}/extensions

%changelog



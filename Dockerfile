FROM centos:centos6
RUN echo proxy=<%= ENV['http_proxy'] %> >> /etc/yum.conf
RUN echo export http_proxy=<%= ENV['http_proxy'] %> >> /etc/profile.d/proxy.sh
RUN echo export https_proxy=<%= ENV['http_proxy'] %> >> /etc/profile.d/proxy.sh
RUN yum clean all
RUN yum install -y sudo openssh-server openssh-clients which curl java-1.7.0-openjdk
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
RUN if ! getent passwd kitchen; then useradd -d /home/kitchen -m -s /bin/bash kitchen; fi
RUN echo kitchen:kitchen | chpasswd
RUN echo 'kitchen ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir -p /etc/sudoers.d
RUN echo 'kitchen ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/kitchen
RUN chmod 0440 /etc/sudoers.d/kitchen
RUN mkdir -p /var/rundeck/jobs/nested
RUN echo -e "<joblist>\n\
  <job>\n\
    <sequence keepgoing='false' strategy='node-first'>\n\
      <command>\n\
        <exec>echo simple-job</exec>\n\
      </command>\n\
    </sequence>\n\
    <loglevel>INFO</loglevel>\n\
    <name>simple-job</name>\n\
    <description></description>\n\
  </job>\n\
</joblist>" > /var/rundeck/jobs/simple-job.xml
RUN echo -e "<joblist>\n\
  <job>\n\
    <sequence keepgoing='false' strategy='node-first'>\n\
      <command>\n\
        <exec>echo nested-job</exec>\n\
      </command>\n\
    </sequence>\n\
    <loglevel>INFO</loglevel>\n\
    <name>job</name>\n\
    <description></description>\n\
    <group>nested</group>\n\
  </job>\n\
</joblist>" > /var/rundeck/jobs/nested/job.xml
